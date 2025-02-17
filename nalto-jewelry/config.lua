Config = {}

Config.RepairCost = 1000 -- Base repair cost
Config.RepairDistance = 3.0 -- How close player needs to be to repair location

Config.RepairLocation = vector4(-1369.4559326172, -304.68801879883, 41.695495605469, 41.453788757324)

Config.Stashes = {
    ['jewelry_crate'] = {
        label = "Jewelry Trolley Storage",
        slots = 30,
        maxweight = 100000, -- 100kg
        coords = vector4(-1366.2867431641, -307.99365234375, 42.16968536377, 54.223552703857)
    },
    ['gem_stash'] = {
        label = "Gem Storage",
        slots = 8,
        maxweight = 50000, -- 50kg
        coords = vector4(-1373.1608886719, -309.75900268555, 42.202774047852, 38.014625549316),
        allowed_items = {  -- Only these items can be stored
            "tanzanite",
            "citrine",
            "ruby",
            "emerald",
            "aquamarine",
            "sapphire",
            "onyx",
            "diamond"
        }
    }
}



Config.CraftingStations = {
    ['molding'] = {
        coords = vector4(-1370.8366699219, -310.62646484375, 41.69556427002, 131.41157531738),
        model = -1107776439,
        progressDuration = 15000,
        animation = {
            dict = "mp_heists@keypad@",
            anim = "idle_a"
        },
        recipes = {
            ['ring_mold'] = {
                label = "Create Ring Mold",
                description = "Create a wax ring mold for casting",
                time = 6000,
                requirements = {
                    {item = "wax_block", amount = 1},
                },
                reward = {
                    item = "wax_ring_mold",
                    amount = 1
                }
            }
        }
    },
    ['drilling'] = {
        coords = vector4(-1373.2135009766, -308.17169189453, 41.69556427002, 41.411582946777),
        model = -769899971,
        progressDuration = 10000,
        animation = {
            dict = "anim@amb@machinery@speed_drill@",
            anim = "operate_02_hi_amy_skater_01"
        },
        recipes = {
            ['ring_casting'] = {
                label = "Cast Silver Ring",
                description = "Create silver ring from wax mold",
                time = 20000,
                requirements = {
                    {item = "wax_ring_mold", amount = 1},
                    {item = "goldore", amount = 1},
                    {item = "plaster", amount = 1}
                },
                reward = {
                    item = "unpolished_ring",
                    amount = 1
                }
            },
            --[[['pendant_casting'] = {
                label = "Cast Gold Ring",
                description = "Create gold ring from wax mold",
                time = 20000,
                requirements = {
                    {item = "wax_ring_mold", amount = 1},
                    {item = "goldore", amount = 1},
                    {item = "plaster", amount = 1}
                },
                reward = {
                    item = "unpolished_ring",
                    amount = 1
                }
            }--]]
        }
    },
    ['polishing'] = {
        coords = vector4(-1367.6354980469, -308.74780273438, 41.69556427002, 221.41162109375),
        model = -517093473,
        progressDuration = 12000,
        animation = {
            dict = "anim@amb@machinery@vertical_mill@",
            anim = "operate_03_amy_skater_01"
        },
        recipes = {
            ['polish_ruby_ring'] = {
                label = "Polish Ruby Ring",
                description = "Polish and finish the cast ruby ring",
                time = 15000,
                requirements = {
                    {item = "unpolished_ring", amount = 1},
                    {item = "polishing_compound", amount = 1},
                    {item = "ruby", amount = 1},
                },
                reward = {
                    item = "nalto_rubyring",
                    amount = 1
                }
            },
            ['polish_sapphire_ring'] = {
                label = "Polish Sapphire Ring",
                description = "Polish and finish the cast sapphire ring",
                time = 15000,
                requirements = {
                    {item = "unpolished_ring", amount = 1},
                    {item = "polishing_compound", amount = 1},
                    {item = "sapphire", amount = 1},
                },
                reward = {
                    item = "nalto_sapphirering",
                    amount = 1
                }
            },
            ['polish_emerald_ring'] = {
                label = "Polish Emerald Ring",
                description = "Polish and finish the cast emerald ring",
                time = 15000,
                requirements = {
                    {item = "unpolished_ring", amount = 1},
                    {item = "polishing_compound", amount = 1},
                    {item = "emerald", amount = 1},
                },
                reward = {
                    item = "nalto_emeraldring",
                    amount = 1
                }
            },
            ['polish_diamond_ring'] = {
                label = "Polish Diamond Ring",
                description = "Polish and finish the cast diamond ring",
                time = 15000,
                requirements = {
                    {item = "unpolished_ring", amount = 1},
                    {item = "polishing_compound", amount = 1},
                    {item = "diamond", amount = 1},
                },
                reward = {
                    item = "nalto_diamondring",
                    amount = 1
                }
            },
            ['polish_citrine_ring'] = {
                label = "Polish Citrine Ring",
                description = "Polish and finish the cast citrine ring",
                time = 15000,
                requirements = {
                    {item = "unpolished_ring", amount = 1},
                    {item = "polishing_compound", amount = 1},
                    {item = "citrine", amount = 1},
                },
                reward = {
                    item = "nalto_citrinering",
                    amount = 1
                }
            },
            ['polish_tanzanite_ring'] = {
                label = "Polish Tanzanite Ring",
                description = "Polish and finish the cast tanzanite ring",
                time = 15000,
                requirements = {
                    {item = "unpolished_ring", amount = 1},
                    {item = "polishing_compound", amount = 1},
                    {item = "tanzanite", amount = 1},
                },
                reward = {
                    item = "nalto_tanzanitering",
                    amount = 1
                }
            },
            ['polish_aquamarine_ring'] = {
                label = "Polish Aquamarine Ring",
                description = "Polish and finish the cast aquamarine ring",
                time = 15000,
                requirements = {
                    {item = "unpolished_ring", amount = 1},
                    {item = "polishing_compound", amount = 1},
                    {item = "aquamarine", amount = 1},
                },
                reward = {
                    item = "nalto_aquamarinering",
                    amount = 1
                }
            },
            ['polish_onyx_ring'] = {
                label = "Polish Onyx Ring",
                description = "Polish and finish the cast onyx ring",
                time = 15000,
                requirements = {
                    {item = "unpolished_ring", amount = 1},
                    {item = "polishing_compound", amount = 1},
                    {item = "onyx", amount = 1},
                },
                reward = {
                    item = "nalto_onyxring",
                    amount = 1
                }
            }
        }
    }
}

Config.RingDurations = {
    ["nalto_aquamarinering"] = 100000,
    ["nalto_citrinering"] = 600000,
    ["nalto_diamondring"] = 3600000,
    ["nalto_emeraldring"] = 3600000,
    ["nalto_onyxring"] = 3600000,
    ["nalto_rubyring"] = 3600000,
    ["nalto_sapphirering"] = 3600000,
    ["nalto_tanzanitering"] = 3600000
}