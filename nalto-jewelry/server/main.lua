local QBCore = exports['qb-core']:GetCoreObject()
local activeRings = {}
local buffActive = false 
local playerBuffStates = {} 
local playerBuffs = {}

RegisterNetEvent('nalto-jewelry:server:setBuffState', function(isActive)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        local citizenId = Player.PlayerData.citizenid
        playerBuffs[citizenId] = isActive
    end
end)

-- Function to get current ring durability
local function GetRingDurability(Player, slot)
    local item = Player.Functions.GetItemBySlot(slot)
    if item then
        if item.info then
            item.info.quality = item.info.quality or 100
            return item.info.quality
        end
        return 100
    end
    return 100
end

local function IsRingActive(citizenid, ringName)
    if activeRings[citizenid] then
        return activeRings[citizenid].itemData.name == ringName
    end
    return false
end

-- Function to clear active ring
local function ClearActiveRing(citizenid)
    if activeRings[citizenid] then
        activeRings[citizenid] = nil
    end
end

local function UseRing(source, item, duration)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    local citizenid = Player.PlayerData.citizenid

    -- Prevent equipping if a ring is already active
    if activeRings[citizenid] then
        TriggerClientEvent('QBCore:Notify', source, "You already have a ring active! Remove it first.", "error")
        return
    end

    -- Remove the ring from inventory when equipped
    Player.Functions.RemoveItem(item.name, 1, item.slot)

    -- Store active ring
    activeRings[citizenid] = {
        itemData = item,
        source = source
    }

    local ringType = string.gsub(item.name, "nalto_", ""):gsub("ring", "")

    -- Trigger ring activation
    TriggerClientEvent("nalto-jewelry:client:" .. ringType, source, item)
end



-- Create ring items
for itemName, duration in pairs(Config.RingDurations) do
    QBCore.Functions.CreateUseableItem(itemName, function(source, item)
        UseRing(source, item, duration)
    end)
end

RegisterNetEvent('nalto-jewelry:server:clearActiveRing', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local citizenid = Player.PlayerData.citizenid
    local activeRing = activeRings[citizenid]

    if activeRing then
        -- Give the ring back to the player
        Player.Functions.AddItem(activeRing.itemData.name, 1, nil, activeRing.itemData.info)

        -- Clear active ring
        activeRings[citizenid] = nil

        -- Notify player
        --TriggerClientEvent('QBCore:Notify', src, "Ring removed and returned to inventory.", "success")
    end
end)


-- Modified repair callback
QBCore.Functions.CreateCallback('nalto-jewelry:server:repairRing', function(source, cb, itemData)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb(false) end

    local item = Player.Functions.GetItemBySlot(itemData.slot)
    
    if item then
        local quality = GetRingDurability(Player, itemData.slot)
        -- Debug print to check repair quality
        print("Repairing ring. Current quality:", quality)
        
        local finalCost = math.ceil(Config.RepairCost * (1 - quality/100))
        
        if Player.Functions.RemoveMoney('cash', finalCost) then
            -- Set quality to 100
            -- Ensure info exists
            local info = item.info or {}
            -- Set quality in info
            info.quality = 100
            
            -- Remove and re-add item with updated info
            Player.Functions.RemoveItem(item.name, 1, item.slot)
            Player.Functions.AddItem(item.name, 1, item.slot, info)
            
            TriggerClientEvent('QBCore:Notify', source, "Ring repaired successfully!", "success")
            cb(true)
        else
            TriggerClientEvent('QBCore:Notify', source, "Not enough money to repair!", "error")
            cb(false)
        end
    else
        TriggerClientEvent('QBCore:Notify', source, "Ring not found!", "error")
        cb(false)
    end
end)

QBCore.Functions.CreateCallback('nalto-jewelry:server:getActiveRing', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb(nil) end

    local activeRing = activeRings[Player.PlayerData.citizenid]
    if activeRing then
        --print("Active ring found:", activeRing.itemData.name)
        cb(string.gsub(activeRing.itemData.name, "nalto_", ""):gsub("ring", " Ring"):gsub("^%l", string.upper))
    else
        --print("No active ring found for:", Player.PlayerData.citizenid)
        cb(nil)
    end
end)


-- Add event handler for inventory durability updates
RegisterNetEvent('inventory:server:ItemDurabilityUpdate', function(source, slot, newQuality)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    local item = Player.Functions.GetItemBySlot(slot)
    if item and string.match(item.name, "nalto_.*ring") then
        -- Ensure item.info exists
        if not item.info then item.info = {} end
        item.info.quality = newQuality
        
        -- Debug print quality update
        print("Ring quality update:", newQuality)
        
        -- If quality hits 0, remove buffs
        if newQuality <= 0 then
            if activeRings[Player.PlayerData.citizenid] and 
               activeRings[Player.PlayerData.citizenid].itemData.slot == slot then
                ClearActiveRing(Player.PlayerData.citizenid)
                TriggerClientEvent('nalto-jewelry:client:removeBuffs', source)
                TriggerClientEvent('QBCore:Notify', source, "Your ring has broken!", "error")
            end
        -- Warn player when quality is low
        elseif newQuality <= 25 then
            TriggerClientEvent('QBCore:Notify', source, "Your ring's quality is getting low!", "warning")
        end
    end
end)

-- Add cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for citizenid, ring in pairs(activeRings) do
            local Player = QBCore.Functions.GetPlayerByCitizenId(citizenid)
            if Player then
                Player.Functions.AddItem(ring.itemData.name, 1, nil, ring.itemData.info)
            end
        end
    end
end)


-- Player robbery event
RegisterNetEvent('inventory:server:RobPlayer', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        ClearActiveRing(Player.PlayerData.citizenid)
    end
end)

QBCore.Functions.CreateCallback('nalto-jewelry:server:checkRequirements', function(source, cb, craftingType, recipeId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return cb(false) end

    print("=== Server Requirements Check ===")
    print("Player:", Player.PlayerData.citizenid)
    print("Crafting Type:", craftingType)
    print("Recipe ID:", recipeId)

    local station = Config.CraftingStations[craftingType]
    if not station then 
        print("Station not found:", craftingType)
        return cb(false) 
    end

    local recipe = station.recipes[recipeId]
    if not recipe then 
        print("Recipe not found:", recipeId)
        return cb(false) 
    end

    -- Check if player has all required items
    local missingItems = {}
    for _, requirement in ipairs(recipe.requirements) do
        local item = Player.Functions.GetItemByName(requirement.item)
        local itemAmount = item and item.amount or 0
        
        print(string.format("Checking item: %s, Required: %d, Has: %d", 
            requirement.item, 
            requirement.amount, 
            itemAmount
        ))
        
        if not item or item.amount < requirement.amount then
            table.insert(missingItems, requirement.item)
        end
    end

    if #missingItems > 0 then
        print("Missing items:", table.concat(missingItems, ", "))
        cb(false)
    else
        print("All requirements met")
        cb(true)
    end
end)

RegisterNetEvent('nalto-jewelry:server:completeCrafting', function(craftingType, recipeId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local station = Config.CraftingStations[craftingType]
    if not station then return end

    local recipe = station.recipes[recipeId]
    if not recipe then return end

    -- Remove required items
    local hasAll = true
    for _, requirement in ipairs(recipe.requirements) do
        if not Player.Functions.RemoveItem(requirement.item, requirement.amount) then
            hasAll = false
            break
        end
    end

    if hasAll then
        -- Give reward
        Player.Functions.AddItem(recipe.reward.item, recipe.reward.amount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[recipe.reward.item], "add")
        TriggerClientEvent('QBCore:Notify', src, "Successfully crafted " .. recipe.reward.amount .. "x " .. 
            QBCore.Shared.Items[recipe.reward.item].label, "success")
    else
        -- Return any items that were removed
        for _, requirement in ipairs(recipe.requirements) do
            Player.Functions.AddItem(requirement.item, requirement.amount)
        end
        TriggerClientEvent('QBCore:Notify', src, "Crafting failed!", "error")
    end
end)

CreateThread(function()
    -- Register stash type with QB-Core
    QBCore.Functions.CreateCallback('jewelry:server:validateItemPlacement', function(source, cb, stashId, slot, itemName)
        if not string.match(stashId, "^jewelry_") then 
            cb(false)
            return
        end
        
        -- Validate slot-specific items
        if slot == 1 and not string.match(itemName, "nalto_.*ring") then
            cb(false)
            return
        end
        if slot == 2 and not string.match(itemName, ".*necklace") then
            cb(false)
            return
        end
        if slot == 3 and not string.match(itemName, ".*bracelet") then
            cb(false)
            return
        end
        
        cb(true)
    end)
end)

-- Update the player loaded event
RegisterServerEvent('QBCore:Server:OnPlayerLoaded')
AddEventHandler('QBCore:Server:OnPlayerLoaded', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        local stashId = "jewelry_" .. Player.PlayerData.citizenid

        -- Create the stash for the player
        exports['ps-inventory']:RegisterStash(stashId, "Jewelry Storage", 5, 50000)

        -- Debugging log
        print("[JEWELRY] Created stash for:", stashId)
    end
end)

RegisterNetEvent("ps-inventory:server:ValidateGemStash", function(stashId, source)
    if stashId ~= "gem_stash" then return end

    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    local allowedGems = {
        tanzanite = true,
        citrine = true,
        ruby = true,
        emerald = true,
        aquamarine = true,
        sapphire = true,
        onyx = true,
        diamond = true
    }

    -- Get stash items
    local stashItems = exports['ps-inventory']:GetStashItems(stashId)
    if not stashItems then return end

    -- Loop through items and return any invalid ones
    for _, item in pairs(stashItems) do
        if not allowedGems[item.name] then
            exports['ps-inventory']:RemoveFromStash(stashId, item.name, item.amount)
            Player.Functions.AddItem(item.name, item.amount)
            TriggerClientEvent("QBCore:Notify", source, "Only gems are allowed in this stash. Your other items have been returned.", "error")
        end
    end
end)

CreateThread(function()
    local stashConfig = Config.Stashes["gem_stash"]
    if stashConfig then
        exports['ps-inventory']:RegisterStash("gem_stash", stashConfig.label, stashConfig.slots, stashConfig.maxweight)
    end
end)

-- Add stash checking event
QBCore.Functions.CreateCallback('jewelry:server:checkStashAccess', function(source, cb, stashId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player and stashId == 'jewelry_' .. Player.PlayerData.citizenid then
        cb(true)
    else
        cb(false)
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player then
        local citizenid = Player.PlayerData.citizenid
        if activeRings[citizenid] then
            -- Save ring to database
            local ringData = activeRings[citizenid].itemData
            exports.oxmysql:execute("INSERT INTO player_rings (citizenid, ring_name, ring_info) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE ring_name = ?, ring_info = ?", 
                { citizenid, ringData.name, json.encode(ringData.info), ringData.name, json.encode(ringData.info) })
            
            -- Remove from active list
            activeRings[citizenid] = nil
        end
    end
end)

RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player then
        local citizenid = Player.PlayerData.citizenid

        -- Check database for saved ring
        exports.oxmysql:execute("SELECT * FROM player_rings WHERE citizenid = ?", { citizenid }, function(result)
            if result and result[1] then
                -- Give ring back to player
                local ringData = result[1]
                Player.Functions.AddItem(ringData.ring_name, 1, nil, json.decode(ringData.ring_info))

                -- Delete from database after restoring
                exports.oxmysql:execute("DELETE FROM player_rings WHERE citizenid = ?", { citizenid })
            end
        end)
    end
end)


RegisterNetEvent('nalto-jewelry:server:setModifiedReward')
AddEventHandler('nalto-jewelry:server:setModifiedReward', function(modifiedAmount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        Player.Functions.AddMoney('cash', modifiedAmount)
    end
end)

RegisterNetEvent('nalto-jewelry:client:testBuff', function()
    local testAmount = 1000
    if buffActive then
        print("[DEBUG] Testing buff with amount:", testAmount)
        TriggerServerEvent('nalto-jewelry:server:modifyMoney', testAmount)
    else
        print("[DEBUG] Buff not active")
    end
end)

RegisterNetEvent('nalto-jewelry:server:activateBuff', function()
    local src = source
    activeBuffs[src] = true
    print("[DEBUG] Server: Activated buff for player", src)
end)

RegisterNetEvent('nalto-jewelry:server:deactivateBuff', function()
    local src = source
    activeBuffs[src] = nil
    print("[DEBUG] Server: Deactivated buff for player", src)
end)

RegisterNetEvent('nalto-jewelry:server:modifyMoney', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then 
        print("[DEBUG] Server: Player not found", src)
        return 
    end
    
    if activeBuffs[src] then
        local modifiedAmount = math.floor(amount * 1.95) -- 15% increase
        print("[DEBUG] Server: Modifying money from", amount, "to", modifiedAmount)
        Player.Functions.AddMoney('cash', modifiedAmount)
        TriggerClientEvent('QBCore:Notify', src, "emerald Ring's power increased your earnings!", "success")
    else
        print("[DEBUG] Server: No active buff for player", src)
        Player.Functions.AddMoney('cash', amount)
    end
end)

function PayoutJob(source, amount)
    if activeBuffs[source] then
        TriggerEvent('nalto-jewelry:server:modifyMoney', source, amount)
    else
        local Player = QBCore.Functions.GetPlayer(source)
        Player.Functions.AddMoney('cash', amount)
    end
end