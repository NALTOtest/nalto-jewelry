Nalto Jewelry System 💍 (OPEN SOURCE)
A comprehensive jewelry system for the FiveM QBCore framework, allowing players to equip, craft, and repair magical rings with unique buffs and effects.

🌟 Features
Wearable Rings with Buffs – Equip rings to gain special abilities (e.g., armor boost, stamina, stress relief).
Ring Durability System – Rings wear down over time and need repairs at a jeweler NPC.
Crafting System – Players can craft rings using materials like wax molds, metal ingots, and polishing compounds.
Multiple Buff Effects – Rings provide unique buffs such as armor regen, money multipliers, and sprint speed boosts.
Inventory & Stash Integration – Uses ps-inventory for ring storage and validation.
Persistence & Server Restart Safety – Rings are saved to the database, ensuring players don't lose them after a restart.
📋 Dependencies
Required resources:

- [qb-core](https://github.com/qbcore-framework/qb-core)
- [qb-target](https://github.com/qbcore-framework/qb-target)
Jewelry MLO (optional) – Needed for ring crafting & repairs.

⚙️ Configuration
This script includes configurable options in config.lua:

Ring durability settings
Crafting material requirements
Jewelry store locations
Ring effects & buffs
💎 Ring Abilities
Each ring provides unique effects when worn:

Sapphire Ring – Overcharges armor when fully protected.
Aquamarine Ring – Boosts swimming speed in water.
Citrine Ring – Reduces stress over time.
Diamond Ring – Grants periodic speed boosts.
Emerald Ring – Increases money earned from activities.
Onyx Ring – Adds temporary extra health (overcharge HP).
Ruby Ring – Provides minor health and armor regeneration.
Tanzanite Ring – Slowly regenerates armor.
🔹 Only one ring can be active at a time!

🏪 Jewelry Crafting & Repair

🔧 Crafting:

Players need wax molds, metal ingots, and polishing compound to create new rings.
Rings start unpolished and must be polished before use.

🛠️ Repairing:

Rings lose durability over time.
Players can repair rings at a jeweler NPC for a configurable cost.

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

    
🚧 Planned Features
🔹 More ring types with unique effects.
🔹 Customizable crafting recipes in the config.
🔹 Additional jewelry items (necklaces, bracelets, etc.).




