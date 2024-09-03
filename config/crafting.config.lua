Config.Crafting = {

    Locations = {

        -- Example of a crafting bench
        ['bench_1'] = {
            name = "Crafting Bench",
            prop = 'gr_prop_gr_bench_01b',
            location = vector4(-61.4, -149.13, 56.33, 66.5),
            recipes = { 'healing', 'tools', 'weapons', 'attachments' },
            blip = { sprite = 110, scale = 0.6, color = 0 },
            --group = { ['police'] = 0 }
        }
    },

    Recipes = {

        ['healing'] = {
            {
                item = 'bandage',
                time = 15,
                amount = 1,
                materials = {
                    { item = "cloth", amount = 10 },
                },
                exp = {
                    required = 0,
                    awarded  = 1
                }
            }
        },

        ['tools'] = {
            {
                item = 'lockpick',
                time = 15,
                amount = 1,
                materials = {
                    { item = "metalscrap", amount = 10 },
                },
                exp = {
                    required = 0,
                    awarded  = 1
                }
            }
        },

        
        ['weapons'] = {
            {
                item = 'weapon_pistol',
                time = 30, -- In Seconds
                amount = 1,
                materials = {
                    { item = "iron", amount = 50 },
                    { item = "steel", amount = 50 },
                    { item = "copper", amount = 50 },
                    { item = "plastic", amount = 20 },
                    { item = "rubber", amount = 15 },
                },
                exp = {
                    required = 0,
                    awarded  = 10
                }
            },

            {
                item = "weapon_combatpistol",
                time = 45,
                amount = 1,
                materials = {
                    { item = "iron", amount = 75 },
                    { item = "steel", amount = 75 },
                    { item = "copper", amount = 75 },
                    { item = "plastic", amount = 40 },
                    { item = "rubber", amount = 25 },
                },
                exp = {
                    required = 0,
                    awarded  = 10
                }
            },

            {
                item = "weapon_snspistol",
                time = 45,
                amount = 1,
                materials = {
                    { item = "iron", amount = 75 },
                    { item = "steel", amount = 75 },
                    { item = "copper", amount = 75 },
                    { item = "plastic", amount = 40 },
                    { item = "rubber", amount = 25 },
                },
                exp = {
                    required = 0,
                    awarded  = 10
                }
            },

            {
                item = "weapon_heavypistol",
                time = 45,
                amount = 1,
                materials = {
                    { item = "iron", amount = 100 },
                    { item = "steel", amount = 100 },
                    { item = "copper", amount = 75 },
                    { item = "plastic", amount = 60 },
                    { item = "rubber", amount = 50 },
                },
                exp = {
                    required = 25,
                    awarded  = 10
                }
            },
        },

        ['attachments'] = {
            {
                item = 'suppressor_attachment',
                time = 25,
                amount = 1,
                materials = {
                    { item = "metalscrap", amount = 50 },
                },
                exp = {
                    required = 10,
                    awarded  = 10
                }
            }
        }
    },
}