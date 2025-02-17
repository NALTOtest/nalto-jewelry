Nalto Jewelry System 💍
A FiveM QBCore jewelry system that allows players to equip, craft, and manage magical rings with unique buffs and effects.

Features
✅ Wearable Rings with Buffs – Players can equip different rings to gain special abilities like increased armor, stamina, health regen, or money boosts.
✅ Ring Durability System – Rings degrade over time and can be repaired at a jeweler shop.
✅ Crafting & Materials – Players can craft rings using special materials from a dedicated jewelry shop.
✅ Buff System – Rings provide active buffs (e.g., faster swimming, sprint boosts, stress relief, extra armor).
✅ Stash & Inventory Integration – Uses ps-inventory for stash management and validation.
✅ Persistence & Server Restart Safety – Rings are returned to players after a server restart, even if they logged out before the restart.






Installation
Add the script to your resources folder.
Ensure ps-inventory and qb-core are installed.
Run this SQL query to enable persistence:
sql
Copy
Edit







CREATE TABLE IF NOT EXISTS player_rings (
    citizenid VARCHAR(50) PRIMARY KEY,
    ring_name VARCHAR(50) NOT NULL,
    ring_info TEXT NOT NULL
);







Add ensure nalto-jewelry to your server.cfg.
Restart your server and enjoy!
Planned Features
🔹 More ring types with unique effects.
🔹 Customizable crafting recipes in the config.
🔹 Additional jewelry items (necklaces, bracelets, etc.).



items

    nalto_aquamarinering       = {name = 'nalto_aquamarinering', label = 'Aquamarine Ring', weight = 1000, type = 'item', image = 'nalto_aquamarinering.png', unique = false, useable = true, shouldClose = true, combinable = nil, description = 'A beautiful aquamarine ring', ["decay"] = 4.0, ["delete"] = false },
    nalto_citrinering          = {name = 'nalto_citrinering', label = 'Citrine Ring', weight = 1000, type = 'item', image = 'nalto_citrinering.png', unique = false, useable = true, shouldClose = true, combinable = nil, description = 'A beautiful citrine ring', ["decay"] = 4.0, ["delete"] = false },
    nalto_diamondring          = {name = 'nalto_diamondring', label = 'Diamond Ring', weight = 1000, type = 'item', image = 'nalto_diamondring.png', unique = false, useable = true, shouldClose = false, combinable = nil, description = 'A beautiful diamond ring', ["decay"] = 4.0, ["delete"] = false },
    nalto_emeraldring          = {name = 'nalto_emeraldring', label = 'Emerald Ring', weight = 1000, type = 'item', image = 'nalto_emeraldring.png', unique = false, useable = true, shouldClose = true, combinable = nil, description = 'A beautiful emerald ring', ["decay"] = 4.0, ["delete"] = false },
    nalto_onyxring             = {name = 'nalto_onyxring', label = 'Onyx Ring', weight = 1000, type = 'item', image = 'nalto_onyxring.png', unique = false, useable = true, shouldClose = true, combinable = nil, description = 'A beautiful onyx ring', ["decay"] = 4.0, ["delete"] = false },
    nalto_rubyring             = {name = 'nalto_rubyring', label = 'Ruby Ring', weight = 1000, type = 'item', image = 'nalto_rubyring.png', unique = false, useable = true, shouldClose = true, combinable = nil, description = 'A beautiful ruby ring', ["decay"] = 4.0, ["delete"] = false },
    nalto_sapphirering         = {name = 'nalto_sapphirering', label = 'Sapphire Ring', weight = 1000, type = 'item', image = 'nalto_sapphirering.png', unique = false, useable = true, shouldClose = true, combinable = nil, description = 'A beautiful sapphire ring', ["decay"] = 4.0, ["delete"] = false },
    nalto_tanzanitering        = {name = 'nalto_tanzanitering', label = 'Tanzanite Ring', weight = 1000, type = 'item', image = 'nalto_tanzanitering.png', unique = false, useable = true, shouldClose = true, combinable = nil, description = 'A beautiful tanzanite ring', ["decay"] = 4.0, ["delete"] = false },

    wax_block                    = {name = 'wax_block', label = 'Jewelry Wax Block', weight = 100, type = 'item', image = 'wax_block.png', unique = false, useable = false, shouldClose = false, combinable = nil, description = 'Block of jewelry wax for making molds'},
    wax_ring_mold                = {name = 'wax_ring_mold', label = 'Wax Ring Mold', weight = 100, type = 'item', image = 'wax_ring_mold.png', unique = false, useable = false, shouldClose = false, combinable = nil, description = 'A wax mold for casting rings'},
    wax_pendant_mold             = {name = 'wax_pendant_mold', label = 'Wax Pendant Mold', weight = 150, type = 'item', image = 'wax_pendant.png', unique = false, useable = false, shouldClose = false, combinable = nil, description = 'A wax mold for casting pendants'},
    metal_ingot                  = {name = 'metal_ingot', label = 'Metal Ingot', weight = 500, type = 'item', image = 'metal_ingot.png', unique = false, useable = false, shouldClose = false, combinable = nil, description = 'Metal ingot for jewelry crafting'},
    plaster                      = {name = 'plaster', label = 'Casting Plaster', weight = 200, type = 'item', image = 'plaster.png', unique = false, useable = false, shouldClose = false, combinable = nil, description = 'Plaster for jewelry casting'},
    unpolished_ring              = {name = 'unpolished_ring', label = 'Unpolished Ring', weight = 100, type = 'item', image = 'unpolished_ring.png', unique = false, useable = false, shouldClose = false, combinable = nil, description = 'An unpolished cast ring'},
    unpolished_pendant           = {name = 'unpolished_pendant', label = 'Unpolished Pendant', weight = 150, type = 'item', image = 'unpolished_pendant.png', unique = false, useable = false, shouldClose = false, combinable = nil, description = 'An unpolished cast pendant'},
    polishing_compound           = {name = 'polishing_compound', label = 'Polishing Compound', weight = 100, type = 'item', image = 'polishing_compound.png', unique = false, useable = false, shouldClose = false, combinable = nil, description = 'Compound for polishing jewelry'},



    





