local QBCore = exports['qb-core']:GetCoreObject()

local activeParticles = {}
local buffActive = false
local moneyMultiplier = 1.95

local buffHandlers = {
    onPlayerDied = {},
    onPlayerKilled = {},
    onRemoveBuffs = {}
}

local function IsItemRing(itemName)
    return string.match(itemName, "nalto_.*ring") ~= nil
end

RegisterNetEvent('nalto-jewelry:client:removeBuffs', function()
    --print("[DEBUG] Removing all buffs...")

    buffActive = false -- Stop buff loops

    -- Reset buffs added by rings only
    SetSwimMultiplierForPlayer(PlayerId(), 1.0)  -- Reset swimming speed
    ResetPedMovementClipset(PlayerPedId(), 0.0)  -- Reset movement
    SetPedArmour(PlayerPedId(), GetPedArmour(PlayerPedId()))  -- Keep armor intact

    -- Notify the server to remove buffs
    local citizenid = QBCore.Functions.GetPlayerData().citizenid
    TriggerServerEvent('buffs:server:RemoveBuff', citizenid, 'health')
    TriggerServerEvent('buffs:server:RemoveBuff', citizenid, 'armor')
    TriggerServerEvent('buffs:server:RemoveBuff', citizenid, 'stamina')
    TriggerServerEvent('buffs:server:RemoveBuff', citizenid, 'stress')

   -- print("[DEBUG] All buffs should be removed now.")
    --QBCore.Functions.Notify("All buffs removed.", "error")
end)



RegisterCommand('removering', function()
    TriggerEvent('nalto-jewelry:client:removeRing')
end)


RegisterKeyMapping('removering', 'Take Off Ring', 'keyboard', 'K')


RegisterNetEvent('nalto-jewelry:client:removeRing', function()
    local PlayerData = QBCore.Functions.GetPlayerData()
    
    -- Get current active ring
    QBCore.Functions.TriggerCallback('nalto-jewelry:server:getActiveRing', function(ring)
        if not ring then
            QBCore.Functions.Notify("No ring currently equipped", "error")
            return
        end

        -- Animation for removing ring
        LoadAnimDict("mp_missheist_countrybank@nervous")
        TaskPlayAnim(PlayerPedId(), "mp_missheist_countrybank@nervous", "nervous_idle", 8.0, -8.0, -1, 49, 0, false, false, false)
        
        QBCore.Functions.Progressbar("removing_ring", "Taking off Ring...", 2000, false, true, {
            disableMovement = false,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true,
        }, {}, {}, {}, function()
            -- Remove buffs
            TriggerEvent('nalto-jewelry:client:removeBuffs')
            
            -- Clear active ring on server
            TriggerServerEvent('nalto-jewelry:server:clearActiveRing')
            
            ClearPedTasks(PlayerPedId())
            QBCore.Functions.Notify("Ring removed", "success")
        end)
    end)
end)

CreateThread(function()
    local npcModel = `mp_m_shopkeep_01`  -- Change to preferred NPC model
    RequestModel(npcModel)
    while not HasModelLoaded(npcModel) do
        Wait(0)
    end
    
    local npc = CreatePed(4, npcModel, -1372.62, -307.33, 42.70 - 1.0, 224.20, false, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    FreezeEntityPosition(npc, true)
    TaskStartScenarioInPlace(npc, "WORLD_HUMAN_STAND_IMPATIENT", 0, true)

    exports['qb-target']:AddTargetEntity(npc, {
        options = {
            {
                type = "client",
                event = "nalto-jewelry:client:openRingMaterialShop",
                icon = "fas fa-gem",
                label = "Buy Ring Crafting Materials"
            },
        },
        distance = 2.5
    })
end)

RegisterNetEvent('nalto-jewelry:client:openRingMaterialShop', function()
    local Player = QBCore.Functions.GetPlayerData()
    if Player.job.name ~= "jeweler" then
        QBCore.Functions.Notify("You must be a jeweler to access this shop!", "error")
        return
    end
    
    local shopItems = {
        label = "Ring Crafting Materials",
        slots = 3,
        items = {
            {name = "wax_block", price = 5, amount = 50, info = {}, type = "item", slot = 1},
            {name = "plaster", price = 5, amount = 50, info = {}, type = "item", slot = 2},
            {name = "polishing_compound", price = 5, amount = 50, info = {}, type = "item", slot = 3},
        }
    }
    TriggerServerEvent("inventory:server:OpenInventory", "shop", "RingCraftingShop", shopItems)
end)


local function CreateMoldingEffects(coords)
    local particles = {}
    
    -- Small sparks effect
    UseParticleFxAssetNextCall("core")
    local sparkEffect = StartParticleFxLoopedAtCoord(
        "proj_molotov_flame_fp", -- More subtle flame effect
        coords.x, coords.y, coords.z + 0.2,
        0.0, 0.0, 0.0,
        0.3, -- Smaller scale
        false, false, false, false
    )
    table.insert(particles, sparkEffect)
    
    -- Heat distortion effect
    UseParticleFxAssetNextCall("core")
    local heatEffect = StartParticleFxLoopedAtCoord(
        "exp_grd_bzgas_smoke",
        coords.x, coords.y, coords.z + 0.1,
        0.0, 0.0, 0.0,
        0.2, -- Very small scale for subtle effect
        false, false, false, false
    )
    table.insert(particles, heatEffect)
    
    -- Small ember effect
    UseParticleFxAssetNextCall("core")
    local emberEffect = StartParticleFxLoopedAtCoord(
        "ent_amb_torch_fire",
        coords.x, coords.y, coords.z + 0.15,
        0.0, 0.0, 0.0,
        0.2, -- Small scale
        false, false, false, false
    )
    table.insert(particles, emberEffect)
    
    -- Create light effect using DrawLight native
    CreateThread(function()
        while true do
            -- Draw point light at the effect location
            DrawLightWithRange(
                coords.x, 
                coords.y, 
                coords.z + 0.2, 
                255,  -- Red
                153,  -- Green
                51,   -- Blue
                3.0,  -- Intensity/Range
                5.0   -- Radius
            )
            Wait(0)
            
            -- Check if any particle effects have been stopped
            local allStopped = true
            for _, effect in ipairs(particles) do
                if DoesParticleFxLoopedExist(effect) then
                    allStopped = false
                    break
                end
            end
            
            -- If all particle effects are stopped, break the light drawing loop
            if allStopped then
                break
            end
        end
    end)
    
    return particles
end

local function CreateCraftingParticles(coords)
    local dict = "core"
    local particleName = "ent_amb_sparking_wires"  -- Welding spark effect
    
    -- Request particle dictionary
    RequestNamedPtfxAsset(dict)
    while not HasNamedPtfxAssetLoaded(dict) do
        Wait(0)
    end
    
    -- Set particle FX asset
    UseParticleFxAssetNextCall(dict)
    
    -- Create the particle effect
    local particle = StartParticleFxLoopedAtCoord(
        particleName,
        coords.x, coords.y, coords.z + 0.7, -- Adjusted height for better visibility
        0.0, 0.0, 0.0, -- rotation
        1.0, -- scale
        false, false, false, false
    )
    
    -- Return the particle handle so we can stop it later
    return particle
end

--[[CreateThread(function()
    exports['qb-target']:AddTargetModel(661958183, { -- Hash for sf_prop_sf_flightcase_01c
        options = {
            {
                type = "client",
                event = "nalto-jewelry:client:openGemStash",
                icon = "fas fa-gem",
                label = "Open Gem Storage",
            },
        },
        distance = 2.5,
    })
end)--]]


-- Add target zone for the stash
CreateThread(function()
    -- Target for specific prop
    exports['qb-target']:AddTargetModel(1158536477, {
        options = {
            {
                type = "client",
                event = "nalto-jewelry:client:openStash",
                icon = "fas fa-box",
                label = "Open Storage",
            },
        },
        distance = 2.5,
    })
end)

RegisterNetEvent('nalto-jewelry:client:openStash', function()
    local stashId = "jewelry_crate"
    local stash = Config.Stashes[stashId]
    
    TriggerServerEvent("inventory:server:OpenInventory", "stash", stashId, {
        maxweight = stash.maxweight,
        slots = stash.slots,
    })
    TriggerEvent("inventory:client:SetCurrentStash", stashId)
end)

RegisterNetEvent('nalto-jewelry:client:openGemStash', function()
    local stashId = "gem_stash"
    local stash = Config.Stashes[stashId]

    TriggerServerEvent("inventory:server:OpenInventory", "stash", stashId, {
        maxweight = stash.maxweight,
        slots = stash.slots,
    })
    TriggerEvent("inventory:client:SetCurrentStash", stashId)

    -- **Trigger a check when the stash closes**
    CreateThread(function()
        Wait(5000) -- Small delay to ensure the player has closed it
        TriggerServerEvent("ps-inventory:server:ValidateGemStash", stashId, source)
    end)
end)

-- Register keybinding
RegisterKeyMapping('checkring', 'Check Active Ring', 'keyboard', 'K')

-- Helper function to load animation dictionary
function LoadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(0)
    end
end

RegisterNetEvent('nalto-jewelry:client:sapphire', function()
    TriggerEvent('nalto-jewelry:client:removeBuffs') -- Ensure previous buffs are cleared
    Wait(500)

    LoadAnimDict("mp_missheist_countrybank@nervous")
    TaskPlayAnim(PlayerPedId(), "mp_missheist_countrybank@nervous", "nervous_idle", 8.0, -8.0, -1, 49, 0, false, false, false)
    
    QBCore.Functions.Progressbar("using_ring", "Putting on Ring..", 2000, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        TriggerEvent("inventory:client:ItemBox", QBCore.Shared.Items['nalto_sapphire-ring'], "remove")
        ClearPedTasks(PlayerPedId())

        buffActive = true
        local maxOvercharge = 15
        local maxVanillaArmor = 100
        local overflowArmor = 0
        local isCharging = false
        local hasFullArmor = false
        local notifiedLowArmor = false

        -- Main armor monitoring thread
        CreateThread(function()
            while buffActive do
                Wait(1000) -- Check every second
                local currentArmor = GetPedArmour(PlayerPedId())
                
                if currentArmor >= 100 then
                    if not hasFullArmor then
                        hasFullArmor = true
                        isCharging = true
                        notifiedLowArmor = false
                        QBCore.Functions.Notify("The Sapphire Ring begins charging your armor!", "success", 5000)
                    end
                else
                    if hasFullArmor then
                        hasFullArmor = false
                        isCharging = false
                        if not notifiedLowArmor then
                            QBCore.Functions.Notify("Sapphire Ring charging paused - needs full armor!", "error", 5000)
                            notifiedLowArmor = true
                        end
                    end
                end
            end
        end)

        -- Charging thread
        CreateThread(function()
            local tickInterval = 3000 -- Update every 3 seconds
            local armorPerTick = maxOvercharge / 15 -- Full charge over 45 seconds

            while buffActive do
                Wait(tickInterval)
                if isCharging then
                    if overflowArmor < maxOvercharge then
                        overflowArmor = math.min(maxOvercharge, overflowArmor + armorPerTick)
                    end
                end
            end
        end)

        -- Damage handling thread
        CreateThread(function()
            while buffActive do
                Wait(0)
                local currentArmor = GetPedArmour(PlayerPedId())
                
                -- If armor was reduced (took damage)
                if currentArmor < maxVanillaArmor and overflowArmor > 0 then
                    local armorLost = maxVanillaArmor - currentArmor
                    local armorToRestore = math.min(armorLost, overflowArmor)
                    
                    -- Restore from overflow
                    SetPedArmour(PlayerPedId(), currentArmor + armorToRestore)
                    overflowArmor = overflowArmor - armorToRestore
                end
            end
        end)

        -- UI Display thread
        CreateThread(function()
            while buffActive do
                -- Only show UI if charging or has overflow armor
                if isCharging or overflowArmor > 0 then
                    -- Draw text with blue color (RGB: 0, 120, 255)
                    SetTextScale(0.35, 0.35)
                    SetTextFont(4)
                    SetTextProportional(1)
                    SetTextColour(0, 120, 255, 255)
                    SetTextDropshadow(0, 0, 0, 0, 255)
                    SetTextEdge(1, 0, 0, 0, 255)
                    SetTextDropShadow()
                    SetTextOutline()
                    SetTextEntry("STRING")
                    
                    -- Only show the overflow armor amount
                    local displayText = isCharging and "CHARGING: " or ""
                    AddTextComponentString(displayText .. "+" .. math.floor(overflowArmor) .. " ARMOR")
                    DrawText(0.82, 0.94)
                end
                
                Wait(0)
            end
        end)

        local function cleanupBuffs()
            if not buffActive then return end
            buffActive = false
            QBCore.Functions.Notify("The Sapphire Ring's effect fades.", "error", 5000)
        end

        -- Store new handlers with cleanup
        buffHandlers.onPlayerDied.sapphire = AddEventHandler('baseevents:onPlayerDied', cleanupBuffs)
        buffHandlers.onPlayerKilled.sapphire = AddEventHandler('baseevents:onPlayerKilled', cleanupBuffs)
        buffHandlers.onRemoveBuffs.sapphire = AddEventHandler('nalto-jewelry:client:removeBuffs', cleanupBuffs)
    end)
end)

RegisterNetEvent('nalto-jewelry:client:aquamarine', function()
    TriggerEvent('nalto-jewelry:client:removeBuffs')                   
    Wait(500)

    LoadAnimDict("mp_missheist_countrybank@nervous")
    TaskPlayAnim(PlayerPedId(), "mp_missheist_countrybank@nervous", "nervous_idle", 8.0, -8.0, -1, 49, 0, false, false, false)

    QBCore.Functions.Progressbar("using_ring", "Putting on Ring..", 2000, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        TriggerEvent("inventory:client:ItemBox", QBCore.Shared.Items['nalto_aquamarine-ring'], "remove")
        ClearPedTasks(PlayerPedId())
        QBCore.Functions.Notify("Maybe go swimming?? IDK..!", "success", 5000)

        buffActive = true
        local speedBoostActive = false

        local function applySpeedBoost()
            if not buffActive then return end
            
            speedBoostActive = true
            local ped = PlayerPedId()
            
            
            SetSwimMultiplierForPlayer(PlayerId(), 1.30) 
            
            
            SetPedMovementClipset(ped, "MOVE_M@QUICK", 1.0)
            
            QBCore.Functions.Notify("🌊 Aquamarine Ring activated!!", "success", 3000)
        end

        local function removeSpeedBoost()
            local ped = PlayerPedId()
            SetSwimMultiplierForPlayer(PlayerId(), 1.0)
            ResetPedMovementClipset(ped, 1.0)
            speedBoostActive = false
        end

        -- Monitor when player enters water
        CreateThread(function()
            while buffActive do
                Wait(1000) -- Check every second
                local ped = PlayerPedId()

                if IsPedSwimming(ped) then
                    if not speedBoostActive then applySpeedBoost() end
                else
                    if speedBoostActive then removeSpeedBoost() end
                end
            end
        end)

        -- Cleanup buffs when the ring is removed or expires
        local function cleanupBuffs()
            if not buffActive then return end
            buffActive = false
            removeSpeedBoost()
            QBCore.Functions.Notify("The Aquamarine Ring's effect fades.", "error", 5000)
        end

        -- Remove buff on death, remove, or unequip
        buffHandlers.onPlayerDied.aquamarine = AddEventHandler('baseevents:onPlayerDied', cleanupBuffs)
        buffHandlers.onPlayerKilled.aquamarine = AddEventHandler('baseevents:onPlayerKilled', cleanupBuffs)
        buffHandlers.onRemoveBuffs.aquamarine = AddEventHandler('nalto-jewelry:client:removeBuffs', cleanupBuffs)
    end)
end)

-- Ring: Citrine
RegisterNetEvent('nalto-jewelry:client:citrine', function()
    TriggerEvent('nalto-jewelry:client:removeBuffs')
    Wait(500)

    LoadAnimDict("mp_missheist_countrybank@nervous")
    TaskPlayAnim(PlayerPedId(), "mp_missheist_countrybank@nervous", "nervous_idle", 8.0, -8.0, -1, 49, 0, false, false, false)
    
    QBCore.Functions.Progressbar("using_ring", "Putting on Ring..", 2000, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        TriggerEvent("inventory:client:ItemBox", QBCore.Shared.Items['nalto_citrine-ring'], "remove")
        ClearPedTasks(PlayerPedId())
        QBCore.Functions.Notify("The Citrine Ring glows softly, easing your stress.", "success", 5000)
        
        local buffActive = true

        -- Remove any existing handlers
        if buffHandlers.onPlayerDied.citrine then
            RemoveEventHandler(buffHandlers.onPlayerDied.citrine)
            buffHandlers.onPlayerDied.citrine = nil
        end
        if buffHandlers.onPlayerKilled.citrine then
            RemoveEventHandler(buffHandlers.onPlayerKilled.citrine)
            buffHandlers.onPlayerKilled.citrine = nil
        end
        if buffHandlers.onRemoveBuffs.citrine then
            RemoveEventHandler(buffHandlers.onRemoveBuffs.citrine)
            buffHandlers.onRemoveBuffs.citrine = nil
        end

        CreateThread(function()
            while buffActive do
                Wait(10000)
                if not buffActive then return end
                TriggerServerEvent('hud:server:RelieveStress', 3)
            end
        end)

        local function cleanupBuffs()
            if not buffActive then return end
            buffActive = false
            QBCore.Functions.Notify("The Citrine Ring's calming effect dissipates.", "error", 5000)

            -- Clear our handlers
            if buffHandlers.onPlayerDied.citrine then
                RemoveEventHandler(buffHandlers.onPlayerDied.citrine)
                buffHandlers.onPlayerDied.citrine = nil
            end
            if buffHandlers.onPlayerKilled.citrine then
                RemoveEventHandler(buffHandlers.onPlayerKilled.citrine)
                buffHandlers.onPlayerKilled.citrine = nil
            end
            if buffHandlers.onRemoveBuffs.citrine then
                RemoveEventHandler(buffHandlers.onRemoveBuffs.citrine)
                buffHandlers.onRemoveBuffs.citrine = nil
            end
        end

        -- Store new handlers
        buffHandlers.onPlayerDied.citrine = AddEventHandler('baseevents:onPlayerDied', cleanupBuffs)
        buffHandlers.onPlayerKilled.citrine = AddEventHandler('baseevents:onPlayerKilled', cleanupBuffs)
        buffHandlers.onRemoveBuffs.citrine = AddEventHandler('nalto-jewelry:client:removeBuffs', cleanupBuffs)
    end)
end)

RegisterNetEvent('nalto-jewelry:client:diamond', function()
    TriggerEvent('nalto-jewelry:client:removeBuffs')
    Wait(500)
    
    LoadAnimDict("mp_missheist_countrybank@nervous")
    TaskPlayAnim(PlayerPedId(), "mp_missheist_countrybank@nervous", "nervous_idle", 8.0, -8.0, -1, 49, 0, false, false, false)
    
    QBCore.Functions.Progressbar("using_ring", "Putting on Ring..", 2000, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        TriggerEvent("inventory:client:ItemBox", QBCore.Shared.Items['nalto_diamond-ring'], "remove")
        ClearPedTasks(PlayerPedId())
        QBCore.Functions.Notify("The Diamond Ring's glistens.", "success", 5000)
        
        -- Remove any existing handlers
        if buffHandlers.onPlayerDied.diamond then
            RemoveEventHandler(buffHandlers.onPlayerDied.diamond)
            buffHandlers.onPlayerDied.diamond = nil
        end
        if buffHandlers.onPlayerKilled.diamond then
            RemoveEventHandler(buffHandlers.onPlayerKilled.diamond)
            buffHandlers.onPlayerKilled.diamond = nil
        end
        if buffHandlers.onRemoveBuffs.diamond then
            RemoveEventHandler(buffHandlers.onRemoveBuffs.diamond)
            buffHandlers.onRemoveBuffs.diamond = nil
        end
        
        -- Initialize buff active state
        local buffActive = true
        local speedBoostActive = false
        
        -- Apply stamina buff if ps-buffs is available
        --[[if exports['ps-buffs'] then
            exports['ps-buffs']:StaminaBuffEffect(3600000, 1.0)
        else
            QBCore.Functions.Notify("The buff system is unavailable.", "error", 5000)
        end--]]
        
        -- Function to handle speed boost
        local function applySpeedBoost()
            if not buffActive then return end
            
            speedBoostActive = true
            local ped = PlayerPedId()
            
            -- Set super run
            SetPedMoveRateOverride(ped, 2.0)
            SetRunSprintMultiplierForPlayer(PlayerId(), 1.15)
            
            -- Set super swim
            SetSwimMultiplierForPlayer(PlayerId(), 1.0)
            
            -- Modify movement clipset
            --SetPedMovementClipset(ped, "MOVE_M@QUICK", 1.0)
            
            QBCore.Functions.Notify("⚡ You feel a jolt of energy!", "success", 3000)
            
            -- Remove speed boost after 3 seconds
            SetTimeout(3000, function()
                if speedBoostActive then
                    -- Reset all speed modifications
                    SetPedMoveRateOverride(ped, 1.0)
                    SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
                    SetSwimMultiplierForPlayer(PlayerId(), 1.0)
                    --ResetPedMovementClipset(ped, 1.0)
                    speedBoostActive = false
                    
                    QBCore.Functions.Notify("the feeling faded away", "error", 2000)
                end
            end)
        end
        
        -- Initial speed boost
        applySpeedBoost()
        
        -- Start the periodic speed boost thread
        CreateThread(function()
            while buffActive do
                if not speedBoostActive then  -- Only apply if not already active
                    applySpeedBoost()
                end
                Wait(15000) -- Wait 15 seconds before next boost
            end
        end)
        
        local function cleanupBuffs()
            if not buffActive then return end
            
            buffActive = false
            QBCore.Functions.Notify("The Diamond Ring's focusing power fades.", "error", 5000)
        
            -- Clear speed boost
            if speedBoostActive then
                local ped = PlayerPedId()
                SetPedMoveRateOverride(ped, 1.0)
                SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
                SetSwimMultiplierForPlayer(PlayerId(), 1.0)
                ResetPedMovementClipset(ped, 1.0)
                speedBoostActive = false
            end
        
            -- ✅ **Properly remove stamina buff if ps-buffs has a removal function**
            if exports['ps-buffs'] and exports['ps-buffs'].RemoveBuffEffect then
                exports['ps-buffs']:RemoveBuffEffect("StaminaBuffEffect") -- Remove the stamina effect
            end
        
            -- Clear event handlers
            if buffHandlers.onPlayerDied.diamond then
                RemoveEventHandler(buffHandlers.onPlayerDied.diamond)
                buffHandlers.onPlayerDied.diamond = nil
            end
            if buffHandlers.onPlayerKilled.diamond then
                RemoveEventHandler(buffHandlers.onPlayerKilled.diamond)
                buffHandlers.onPlayerKilled.diamond = nil
            end
            if buffHandlers.onRemoveBuffs.diamond then
                RemoveEventHandler(buffHandlers.onRemoveBuffs.diamond)
                buffHandlers.onRemoveBuffs.diamond = nil
            end
        end
        
        -- Store new handlers
        buffHandlers.onPlayerDied.diamond = AddEventHandler('baseevents:onPlayerDied', cleanupBuffs)
        buffHandlers.onPlayerKilled.diamond = AddEventHandler('baseevents:onPlayerKilled', cleanupBuffs)
        buffHandlers.onRemoveBuffs.diamond = AddEventHandler('nalto-jewelry:client:removeBuffs', cleanupBuffs)
    end)
end)

-- Ring: emerald- must link to your own robbery or rewards etc...
RegisterNetEvent('nalto-jewelry:client:emerald', function()
    -- Debug print
    --print("[DEBUG] emerald ring event triggered")
    
    TriggerEvent('nalto-jewelry:client:removeBuffs')
    Wait(500)
    
    LoadAnimDict("mp_missheist_countrybank@nervous")
    TaskPlayAnim(PlayerPedId(), "mp_missheist_countrybank@nervous", "nervous_idle", 8.0, -8.0, -1, 49, 0, false, false, false)
    
    QBCore.Functions.Progressbar("using_ring", "Putting on Ring..", 2000, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        -- Debug print
        --print("[DEBUG] Ring equip animation completed")
        
        buffActive = true
        TriggerEvent("inventory:client:ItemBox", QBCore.Shared.Items['nalto_emerald-ring'], "remove")
        ClearPedTasks(PlayerPedId())
        QBCore.Functions.Notify("The emerald Ring glows with a green hue.", "success", 5000)
        
        -- Apply buff immediately
        TriggerServerEvent('nalto-jewelry:server:activateBuff')
        
        -- Debug print
        --print("[DEBUG] Buff activated, multiplier:", moneyMultiplier)
        
        local function cleanupBuffs()
            if not buffActive then return end
            buffActive = false
            
            -- Debug print
            --print("[DEBUG] Cleaning up buffs")
            
            TriggerServerEvent('nalto-jewelry:server:deactivateBuff')
            QBCore.Functions.Notify("The emerald Ring's power fades...", "error", 5000)
        end
        
        -- Set timeout for buff expiration
        SetTimeout(300000000, cleanupBuffs) 
    end)
end)

RegisterNetEvent('nalto-jewelry:client:onyx', function()
    -- Ensure previous buffs are cleared before applying new ones
    TriggerEvent('nalto-jewelry:client:removeBuffs') 
    Wait(500)

    LoadAnimDict("mp_missheist_countrybank@nervous")
    TaskPlayAnim(PlayerPedId(), "mp_missheist_countrybank@nervous", "nervous_idle", 
        8.0, -8.0, -1, 49, 0, false, false, false)

    QBCore.Functions.Progressbar("using_ring", "Putting on Ring..", 2000, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        TriggerEvent("inventory:client:ItemBox", QBCore.Shared.Items['nalto_onyx-ring'], "remove")
        ClearPedTasks(PlayerPedId())
        QBCore.Functions.Notify("💀 The Onyx Rings energy surrounds you!", "success", 5000)

        local buffActive = true
        local maxOverchargeHP = 15  -- Maximum "buffer" HP
        local regenRate = 1  -- HP per second when at full health
        local isRegenerating = false
        local overchargeHP = 0

        local ped = PlayerPedId()

        -- **Overcharge HP System (Separate Buffer)**
        CreateThread(function()
            while buffActive do
                Wait(8000)  -- Check every second

                local currentHP = GetEntityHealth(ped)

                -- If at full health (200), start regenerating overcharge HP
                if currentHP >= 200 then
                    if not isRegenerating then
                        isRegenerating = true
                        QBCore.Functions.Notify("💀 The Onyx Ring starts regenerating extra health...", "success", 3000)
                    end

                    if overchargeHP < maxOverchargeHP then
                        overchargeHP = math.min(overchargeHP + regenRate, maxOverchargeHP)
                    end
                else
                    isRegenerating = false
                end
            end
        end)

        -- **Damage Handling (Overcharge HP First)**
        CreateThread(function()
            while buffActive do
                Wait(0)
                local currentHP = GetEntityHealth(ped)

                -- If player takes damage, remove from overcharge HP first
                if currentHP < 200 and overchargeHP > 0 then
                    local damageTaken = 200 - currentHP
                    local absorbAmount = math.min(overchargeHP, damageTaken)

                    overchargeHP = overchargeHP - absorbAmount
                    SetEntityHealth(ped, currentHP + absorbAmount) -- Restore health from buffer
                end
            end
        end)

        -- **Red UI Display for Extra HP (Separate Bar)**
CreateThread(function()
    while buffActive do
        if overchargeHP > 0 then
            local screenX, screenY = 0.85, 0.92 -- Position on screen
            local barWidth, barHeight = 0.12, 0.02 -- Bar size

            -- Draw Background Bar (Black Transparent)
            DrawRect(screenX, screenY, barWidth, barHeight, 0, 0, 0, 150)

            -- Draw Filled Bar (Red)
            local filledWidth = (overchargeHP / maxOverchargeHP) * barWidth
            DrawRect(screenX - (barWidth - filledWidth) / 2, screenY, filledWidth, barHeight, 200, 0, 0, 200)

            -- Draw Text Above Bar
            SetTextScale(0.3, 0.3)
            SetTextFont(4)
            SetTextProportional(1)
            SetTextColour(255, 255, 255, 255) -- White text
            SetTextOutline()
            SetTextEntry("STRING")
            AddTextComponentString("💛 HP Overflow: " .. math.floor(overchargeHP))
            DrawText(screenX - 0.05, screenY - 0.015)
        end
        Wait(0)
    end
end)


        -- **Cleanup Buffs When Removing**
        local function cleanupBuffs()
            if not buffActive then return end
            buffActive = false
            
            -- Reset Overcharge HP
            overchargeHP = 0

            QBCore.Functions.Notify("The Onyx Ring's dark energy dissipates...", "error", 5000)
        end

        -- Store Buff Cleanup Handlers (Prevents Buff Exploits)
        buffHandlers.onPlayerDied.onyx = AddEventHandler('baseevents:onPlayerDied', cleanupBuffs)
        buffHandlers.onPlayerKilled.onyx = AddEventHandler('baseevents:onPlayerKilled', cleanupBuffs)
        buffHandlers.onRemoveBuffs.onyx = AddEventHandler('nalto-jewelry:client:removeBuffs', cleanupBuffs)
    end)
end)

RegisterNetEvent('nalto-jewelry:client:ruby', function()
    TriggerEvent('nalto-jewelry:client:removeBuffs') -- Ensure buffs are cleared
    Wait(500)
    
    LoadAnimDict("mp_missheist_countrybank@nervous")
    TaskPlayAnim(PlayerPedId(), "mp_missheist_countrybank@nervous", "nervous_idle", 8.0, -8.0, -1, 49, 0, false, false, false)
    
    QBCore.Functions.Progressbar("using_ring", "Putting on Ring..", 2000, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        TriggerEvent("inventory:client:ItemBox", QBCore.Shared.Items['nalto_ruby-ring'], "remove")
        ClearPedTasks(PlayerPedId())
        QBCore.Functions.Notify("🔥 The Ruby Ring ignites with fiery energy!", "success", 5000)
        
        -- ✅ Load Particle Dictionary
        --[[local particleDict = "core"
        local particleName = "proj_molotov_flame" -- Red flame effect
        
        RequestNamedPtfxAsset(particleDict)
        while not HasNamedPtfxAssetLoaded(particleDict) do
            Wait(10) -- Wait for it to load
        end
        
        -- ✅ Get the Finger Bone
        local ped = PlayerPedId()
        local boneIndex = GetPedBoneIndex(ped, 18905) -- 18905 = Right Index Finger
        
        -- ✅ Start Particle Effect (Offset for Visibility)
        UseParticleFxAssetNextCall(particleDict)
        local particleEffect = StartParticleFxLoopedOnEntityBone(
            particleName,
            ped, boneIndex,
            0.02, 0.0, 5.9,  -- Small offset to fit on the finger
            0.0, 0.0, 0.0,  -- No rotation needed
            1.7,  -- Scale (adjust if too big)
            false, false, false
        )--]]
        
        -- ✅ Keep the effect active and manage buffs until the ring is removed
        local buffActive = true
        CreateThread(function()
            while buffActive do
                Wait(5000) -- Check every 5 seconds
                local ped = PlayerPedId()
                
                -- Armor regeneration
                local armor = GetPedArmour(ped)
                if armor < 5 then
                    SetPedArmour(ped, armor + 1)
                end
                
                -- Health regeneration
                local health = GetEntityHealth(ped)
                local maxHealth = GetEntityMaxHealth(ped)
                if health < maxHealth and health > 0 then -- Only heal if player is alive
                    SetEntityHealth(ped, math.min(health + 2, maxHealth)) -- Heal 2 HP every 5 seconds
                end
            end
        end)
        
        local function cleanupBuffs()
            if not buffActive then return end
            buffActive = false
            StopParticleFxLooped(particleEffect, false) -- Stop the effect
            QBCore.Functions.Notify("The Ruby Ring's power fades.", "error", 5000)
        end
        
        -- Cleanup when ring effect is removed
        buffHandlers.onPlayerDied.ruby = AddEventHandler('baseevents:onPlayerDied', cleanupBuffs)
        buffHandlers.onPlayerKilled.ruby = AddEventHandler('baseevents:onPlayerKilled', cleanupBuffs)
        buffHandlers.onRemoveBuffs.ruby = AddEventHandler('nalto-jewelry:client:removeBuffs', cleanupBuffs)
    end)
end)


-- Ring: Tanzanite
RegisterNetEvent('nalto-jewelry:client:tanzanite', function()
    TriggerEvent('nalto-jewelry:client:removeBuffs') -- Ensure buffs are cleared
    Wait(500)

    LoadAnimDict("mp_missheist_countrybank@nervous")
    TaskPlayAnim(PlayerPedId(), "mp_missheist_countrybank@nervous", "nervous_idle", 8.0, -8.0, -1, 49, 0, false, false, false)

    QBCore.Functions.Progressbar("using_ring", "Putting on Ring..", 2000, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = false,
    }, {}, {}, {}, function()
        TriggerEvent("inventory:client:ItemBox", QBCore.Shared.Items['nalto_tanzanite-ring'], "remove")
        ClearPedTasks(PlayerPedId())
        QBCore.Functions.Notify("You start to feel a bit more sturdy.", "success", 5000)
        
        local buffActive = true
        local maxArmor = 15
        --local maxHealth = 5

        -- Remove any existing handlers for this ring
        if buffHandlers.onPlayerDied.tanzanite then
            RemoveEventHandler(buffHandlers.onPlayerDied.tanzanite)
            buffHandlers.onPlayerDied.tanzanite = nil
        end
        if buffHandlers.onPlayerKilled.tanzanite then
            RemoveEventHandler(buffHandlers.onPlayerKilled.tanzanite)
            buffHandlers.onPlayerKilled.tanzanite = nil
        end
        if buffHandlers.onRemoveBuffs.tanzanite then
            RemoveEventHandler(buffHandlers.onRemoveBuffs.tanzanite)
            buffHandlers.onRemoveBuffs.tanzanite = nil
        end

        CreateThread(function()
            while buffActive do
                Wait(6000)
                local ped = PlayerPedId()
                if GetPedArmour(ped) < maxArmor then
                    SetPedArmour(ped, math.min(GetPedArmour(ped) + 3, maxArmor))
                end
                --[[if GetEntityHealth(ped) < maxHealth then
                    SetEntityHealth(ped, math.min(GetEntityHealth(ped) + 1, maxHealth))
                end--]]
            end
        end)

        local function cleanupBuffs()
            if not buffActive then return end -- Prevent multiple cleanups
            buffActive = false
            QBCore.Functions.Notify("The tanzanite Ring's power fades.", "error", 5000)
            
            -- Clear our handlers
            if buffHandlers.onPlayerDied.tanzanite then
                RemoveEventHandler(buffHandlers.onPlayerDied.tanzanite)
                buffHandlers.onPlayerDied.tanzanite = nil
            end
            if buffHandlers.onPlayerKilled.tanzanite then
                RemoveEventHandler(buffHandlers.onPlayerKilled.tanzanite)
                buffHandlers.onPlayerKilled.tanzanite = nil
            end
            if buffHandlers.onRemoveBuffs.tanzanite then
                RemoveEventHandler(buffHandlers.onRemoveBuffs.tanzanite)
                buffHandlers.onRemoveBuffs.tanzanite = nil
            end
        end

        -- Store new handlers
        buffHandlers.onPlayerDied.tanzanite = AddEventHandler('baseevents:onPlayerDied', cleanupBuffs)
        buffHandlers.onPlayerKilled.tanzanite = AddEventHandler('baseevents:onPlayerKilled', cleanupBuffs)
        buffHandlers.onRemoveBuffs.tanzanite = AddEventHandler('nalto-jewelry:client:removeBuffs', cleanupBuffs)
    end)
end)

CreateThread(function()
  exports['qb-target']:AddTargetModel(765424411, {
      options = {
          {
              type = "client",
              event = "nalto-jewelry:client:openRepairMenu",
              icon = "fas fa-ring",
              label = "Repair Rings",
          },
      },
      distance = 2.5,
  })
end)

RegisterNetEvent('nalto-jewelry:client:openRepairMenu', function()
    local PlayerData = QBCore.Functions.GetPlayerData()
    local menu = {
        {
            header = "Ring Repair Shop",
            isMenuHeader = true
        }
    }
    
    for slot, item in pairs(PlayerData.items) do
        if string.match(item.name, "nalto_.*ring") then
            -- Use quality instead of durability
            local quality = (item.info and item.info.quality) or 100
            local repairCost = math.ceil(Config.RepairCost * (1 - quality/100))
            
            menu[#menu + 1] = {
                header = string.format("%s - Quality: %d%%", 
                    string.gsub(item.name, "nalto_", ""):gsub("ring", " Ring"):gsub("^%l", string.upper),
                    math.floor(quality)
                ),
                txt = string.format("Repair Cost: $%d", repairCost),
                params = {
                    event = "nalto-jewelry:client:repairRing",
                    args = {
                        slot = slot,
                        name = item.name
                    }
                }
            }
        end
    end
    
    menu[#menu + 1] = {
        header = "Close",
        txt = "",
        params = {
            event = "qb-menu:client:closeMenu"
        }
    }
    
    exports['qb-menu']:openMenu(menu)
end)

RegisterNetEvent('nalto-jewelry:client:repairRing', function(data)
    local PlayerData = QBCore.Functions.GetPlayerData()

    if PlayerData.job.name ~= "jeweler" then
        QBCore.Functions.Notify("You must be a jeweler to repair rings!", "error")
        return
    end

    if not data or not data.slot then return end
  
    local itemData = {
        slot = data.slot,
        name = data.name
    }
  
    QBCore.Functions.TriggerCallback('nalto-jewelry:server:repairRing', function(success)
        if success then
            --QBCore.Functions.Notify("Ring repaired successfully!", "success")
        else
            QBCore.Functions.Notify("Failed to repair ring!", "error")
        end
    end, itemData)
end)


RegisterNetEvent('inventory:client:ItemBox', function(itemData, type)
    if type == "remove" and itemData and string.match(itemData.name, "nalto_.*ring") then
        QBCore.Functions.TriggerCallback('nalto-jewelry:server:getActiveRing', function(activeRing)
            if activeRing and activeRing == string.gsub(itemData.name, "nalto_", ""):gsub("ring", " Ring"):gsub("^%l", string.upper) then
                -- Active ring removed from inventory
                print("Active ring removed from inventory:", activeRing)
                TriggerEvent('nalto-jewelry:client:removeBuffs')
                TriggerServerEvent('nalto-jewelry:server:clearActiveRing')
            end
        end)
    end
end)


RegisterCommand('activering', function()
  QBCore.Functions.TriggerCallback('nalto-jewelry:server:getActiveRing', function(ring)
      if ring then
          QBCore.Functions.Notify("Active Ring: " .. ring, "primary")
      else
          QBCore.Functions.Notify("No active ring", "error")
      end
  end)
end)

-- Periodically validate active ring state
--[[CreateThread(function()
    while true do
        Wait(30000) -- Check every 1 second
        local PlayerData = QBCore.Functions.GetPlayerData()
        local citizenid = PlayerData.citizenid

        QBCore.Functions.TriggerCallback('nalto-jewelry:server:getActiveRing', function(activeRing)
            if activeRing then
                local foundRing = false
                for _, item in pairs(PlayerData.items) do
                    if string.match(item.name, "nalto_.*ring") then
                        foundRing = true
                        break
                    end
                end

                if not foundRing then
                    print("Active ring no longer in inventory, clearing effects.")
                    TriggerEvent('nalto-jewelry:client:removeBuffs')
                    TriggerServerEvent('nalto-jewelry:server:clearActiveRing')
                end
            end
        end)
    end
end)--]]


-- Ensure only one ring is active at a time
RegisterNetEvent('nalto-jewelry:client:setActiveRing', function(ringName)
  TriggerEvent('nalto-jewelry:client:removeBuffs') -- Remove any existing buffs
  TriggerEvent("nalto-jewelry:client:" .. ringName) -- Activate the selected ring
end)

AddEventHandler('baseevents:onPlayerDied', function()
    TriggerEvent('nalto-jewelry:client:removeBuffs')
    TriggerServerEvent('nalto-jewelry:server:clearActiveRing') -- Ensure server clears ring
end)

AddEventHandler('baseevents:onPlayerKilled', function()
    TriggerEvent('nalto-jewelry:client:removeBuffs')
    TriggerServerEvent('nalto-jewelry:server:clearActiveRing') -- Ensure server clears ring
end)


AddEventHandler('onResourceStop', function(resourceName)
  if (GetCurrentResourceName() ~= resourceName) then return end
  TriggerEvent('nalto-jewelry:client:removeBuffs')
end)

CreateThread(function()
    for stationType, station in pairs(Config.CraftingStations) do
        exports['qb-target']:AddTargetModel(station.model, {
            options = {
                {
                    type = "client",
                    event = "nalto-jewelry:client:openCraftingMenu",
                    icon = "fas fa-gem",
                    label = "Use " .. stationType:gsub("^%l", string.upper) .. " Station",
                    craftingType = stationType
                },
            },
            distance = 2.5,
        })
    end
end)

RegisterNetEvent('nalto-jewelry:client:openCraftingMenu', function(data)
    local PlayerData = QBCore.Functions.GetPlayerData()
    
    if PlayerData.job.name ~= "jeweler" then
        QBCore.Functions.Notify("You must be a jeweler to craft items!", "error")
        return
    end

    if not data.craftingType then return end
    
    local station = Config.CraftingStations[data.craftingType]
    if not station then return end

    -- Debug print
    print("Opening crafting menu for station type:", data.craftingType)

    local menu = {
        {
            header = data.craftingType:gsub("^%l", string.upper) .. " Station",
            isMenuHeader = true
        }
    }

    for recipeId, recipe in pairs(station.recipes) do
        local canCraft = true
        local ingredientText = "Requirements:\n"
        
        -- Enhanced debug checking for items
        for _, requirement in ipairs(recipe.requirements) do
            local hasItem = QBCore.Functions.HasItem(requirement.item, requirement.amount)
            print(string.format("Checking item: %s, amount needed: %d, has item: %s", 
                requirement.item, 
                requirement.amount, 
                tostring(hasItem)
            ))
            
            if not hasItem then
                canCraft = false
                print("Missing required item:", requirement.item)
            end
            
            -- Verify item exists in shared items
            local itemData = QBCore.Shared.Items[requirement.item]
            if not itemData then
                print("WARNING: Item not found in shared items:", requirement.item)
            end
            
            ingredientText = ingredientText .. "- " .. requirement.amount .. "x " .. 
                (itemData and itemData.label or requirement.item) .. "\n"
        end

        menu[#menu + 1] = {
            header = recipe.label,
            txt = recipe.description .. "\n" .. ingredientText,
            params = {
                event = "nalto-jewelry:client:startCrafting",
                args = {
                    craftingType = data.craftingType,
                    recipeId = recipeId
                }
            },
            disabled = not canCraft
        }
    end

    menu[#menu + 1] = {
        header = "Close",
        txt = "",
        params = {
            event = "qb-menu:client:closeMenu"
        }
    }

    exports['qb-menu']:openMenu(menu)
end)

RegisterNetEvent('nalto-jewelry:client:startCrafting', function(data)
    if not data.craftingType or not data.recipeId then return end
    
    local station = Config.CraftingStations[data.craftingType]
    if not station then return end
    
    local recipe = station.recipes[data.recipeId]
    if not recipe then return end

    QBCore.Functions.TriggerCallback('nalto-jewelry:server:checkRequirements', function(hasRequirements)
        if not hasRequirements then
            QBCore.Functions.Notify("You don't have the required items!", "error")
            return
        end

        -- Load animation dict
        if not HasAnimDictLoaded(station.animation.dict) then
            RequestAnimDict(station.animation.dict)
            while not HasAnimDictLoaded(station.animation.dict) do
                Wait(0)
            end
        end

        local playerPed = PlayerPedId()

        -- Drilling
        if data.craftingType == "drilling" then
            local targetCoords = vector3(-1372.58, -308.84, 42.70)
            local targetHeading = 41.12

            -- Walk to position
            local playerCoords = GetEntityCoords(playerPed)
            local distance = #(playerCoords - targetCoords)

            if distance > 0.5 then
                TaskGoStraightToCoord(playerPed, targetCoords.x, targetCoords.y, targetCoords.z, 1.0, -1, targetHeading, 0.0)
                while #(GetEntityCoords(playerPed) - targetCoords) > 0.2 do Wait(100) end
            end

            -- Lock player and start animation
            SetEntityHeading(playerPed, targetHeading)
            FreezeEntityPosition(playerPed, true)
            SetEntityCollision(playerPed, false, true)
            TaskPlayAnim(playerPed, 'anim@amb@machinery@speed_drill@', 'operate_02_hi_amy_skater_01', 3.0, 3.0, -1, 1, 0, false, false, false)

            -- Load and play sound
            RequestScriptAudioBank('DLC_HEIST_FLEECA_SOUNDSET', false)
            local soundId = GetSoundId()
            PlaySoundFromEntity(soundId, 'Drill', playerPed, 'DLC_HEIST_FLEECA_SOUNDSET', true, 0)

            -- Progress bar
            QBCore.Functions.Progressbar("crafting_" .. data.recipeId, "Drilling " .. recipe.label .. "...", 
                recipe.time, false, true, {
                    disableMovement = true,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true,
                }, {}, {}, {}, function()
                    StopSound(soundId)
                    ReleaseSoundId(soundId)
                    ClearPedTasks(playerPed)
                    FreezeEntityPosition(playerPed, false)
                    SetEntityCollision(playerPed, true, true)
                    TriggerServerEvent("nalto-jewelry:server:completeCrafting", data.craftingType, data.recipeId)
                end, function()
                    StopSound(soundId)
                    ReleaseSoundId(soundId)
                    ClearPedTasks(playerPed)
                    FreezeEntityPosition(playerPed, false)
                    SetEntityCollision(playerPed, true, true)
                end)
        
        -- Polishing
        elseif data.craftingType == "polishing" then
            local targetCoords = vector3(-1368.51, -307.86, 42.70)
            local targetHeading = 223.20

            -- Walk to position
            local playerCoords = GetEntityCoords(playerPed)
            local distance = #(playerCoords - targetCoords)

            if distance > 0.5 then
                TaskGoStraightToCoord(playerPed, targetCoords.x, targetCoords.y, targetCoords.z, 1.0, -1, targetHeading, 0.0)
                while #(GetEntityCoords(playerPed) - targetCoords) > 0.2 do Wait(100) end
            end

            -- Lock player and start animation
            SetEntityHeading(playerPed, targetHeading)
            FreezeEntityPosition(playerPed, true)
            SetEntityCollision(playerPed, false, true)
            TaskPlayAnim(playerPed, "anim@amb@machinery@vertical_mill@", "operate_03_amy_skater_01", 3.0, 3.0, -1, 1, 0, false, false, false)

            -- Progress bar
            QBCore.Functions.Progressbar("crafting_" .. data.recipeId, "Polishing " .. recipe.label .. "...", 
                recipe.time, false, true, {
                    disableMovement = true,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true,
                }, {}, {}, {}, function()
                    ClearPedTasks(playerPed)
                    FreezeEntityPosition(playerPed, false)
                    SetEntityCollision(playerPed, true, true)
                    TriggerServerEvent("nalto-jewelry:server:completeCrafting", data.craftingType, data.recipeId)
                end, function()
                    ClearPedTasks(playerPed)
                    FreezeEntityPosition(playerPed, false)
                    SetEntityCollision(playerPed, true, true)
                end)

        -- Other crafting types
        else
            QBCore.Functions.Progressbar("crafting_" .. data.recipeId, "Crafting " .. recipe.label .. "...", 
                recipe.time, false, true, {
                    disableMovement = true,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true,
                }, {
                    animDict = station.animation.dict,
                    anim = station.animation.anim,
                    flags = 1,
                }, {}, {}, function()
                    ClearPedTasks(playerPed)
                    TriggerServerEvent("nalto-jewelry:server:completeCrafting", data.craftingType, data.recipeId)
                end, function()
                    ClearPedTasks(playerPed)
                end)
        end
    end, data.craftingType, data.recipeId)
end)
