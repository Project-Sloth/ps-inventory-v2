Config.Shops = {

    -- Grocery Stores
    ['grocery'] = {
        name = "Grocery Store",
        items = { 
            { item = 'tosti',         price = 2 },
            { item = 'water_bottle',  price = 2 },
            { item = 'kurkakola',     price = 2 },
            { item = 'twerks_candy',  price = 2 },
            { item = 'snikkel_candy', price = 2 },
            { item = 'sandwich',      price = 2 },
            { item = 'beer',          price = 7 },
            { item = 'whiskey',       price = 10 },
            { item = 'vodka',         price = 12 },
            { item = 'bandage',       price = 100 },
            { item = 'lighter',       price = 2 },
            { item = 'rolling_paper', price = 2 },
        },
        locations = {
            vector4(24.47, -1346.62, 29.5, 271.66),
            vector4(-3039.54, 584.38, 7.91, 17.27),
            vector4(-3245.76, 1005.25, 12.83, 269.45),
            vector4(1728.07, 6415.63, 35.04, 242.95),
            vector4(1959.82, 3740.48, 32.34, 301.57),
            vector4(549.13, 2670.85, 42.16, 99.39),
            vector4(2677.47, 3279.76, 55.24, 335.08),
            vector4(2556.66, 380.84, 108.62, 356.67),
            vector4(379.97, 357.3, 102.56, 26.42),
            vector4(-47.02, -1758.23, 29.42, 45.05),
            vector4(-706.06, -913.97, 19.22, 88.04),
            vector4(-1820.02, 794.03, 138.09, 135.45),
            vector4(1697.87, 4922.96, 42.06, 324.71)
        },
        npc = {  model = "mp_m_shopkeep_01", scenario = "WORLD_HUMAN_STAND_MOBILE" },
        blip = { sprite = 52, scale = 0.6, color = 0 }
    },

    -- Liquor Stores
    ['liquor'] = {
        name = "Liquor Store",
        items = { 
            { item = 'beer',    price = 7 },
            { item = 'whiskey', price = 10 },
            { item = 'vodka',   price = 12 },
        },
        locations = {
            vector4(-1221.58, -908.15, 12.33, 35.49),
            vector4(-1486.59, -377.68, 40.16, 139.51),
            vector4(-2966.39, 391.42, 15.04, 87.48),
            vector4(1165.17, 2710.88, 38.16, 179.43),
            vector4(1134.2, -982.91, 46.42, 277.24)
        },
        npc = {  model = "mp_m_shopkeep_01", scenario = "WORLD_HUMAN_STAND_MOBILE" },
        blip = { sprite = 52, scale = 0.6, color = 0 }
    },

    -- Hardware Stores
    ['hardware'] = {
        name = "Hardware Store",
        items = { 
            { item = 'lockpick',          price = 200 },
            { item = 'weapon_wrench',     price = 250 },
            { item = 'weapon_hammer',     price = 250 },
            { item = 'repairkit',         price = 250 },
            { item = 'screwdriverset',    price = 350 },
            { item = 'phone',             price = 850 },
            { item = 'radio',             price = 250 },
            { item = 'binoculars',        price = 50 },
            { item = 'firework1',         price = 50 },
            { item = 'firework2',         price = 50 },
            { item = 'firework3',         price = 50 },
            { item = 'firework4',         price = 50 },
            { item = 'fitbit',            price = 400 },
            { item = 'cleaningkit',       price = 150 },
            { item = 'advancedrepairkit', price = 500 },
        },
        locations = {
            vector4(45.68, -1749.04, 29.61, 53.13),
            vector4(2747.71, 3472.85, 55.67, 255.08),
            vector4(-421.83, 6136.13, 31.88, 228.2)
        },
        npc = {  model = "mp_m_waremech_01", scenario = "WORLD_HUMAN_CLIPBOARD" },
        blip = { sprite = 402, scale = 0.8, color = 0 }
    },

    -- Ammunation Stores
    ['ammunation'] = {
        name = "Ammunation",
        items = { 
            { item = 'weapon_knife',         price = 250 },
            { item = 'weapon_bat',           price = 250 },
            { item = 'weapon_hatchet',       price = 250 },
            { item = 'pistol_ammo',          price = 250 },
            { item = 'weapon_pistol',        price = 2500, license = 'weapon' },
            { item = 'weapon_snspistol',     price = 1500, license = 'weapon' },
            { item = 'weapon_vintagepistol', price = 4000, license = 'weapon' },
        },
        locations = {
            vector4(-661.96, -933.53, 21.83, 177.05),
            vector4(809.68, -2159.13, 29.62, 1.43),
            vector4(1692.67, 3761.38, 34.71, 227.65),
            vector4(-331.23, 6085.37, 31.45, 228.02),
            vector4(253.63, -51.02, 69.94, 72.91),
            vector4(23.0, -1105.67, 29.8, 162.91),
            vector4(2567.48, 292.59, 108.73, 349.68),
            vector4(-1118.59, 2700.05, 18.55, 221.89),
            vector4(841.92, -1035.32, 28.19, 1.56),
            vector4(-1304.19, -395.12, 36.7, 75.03),
            vector4(-3173.31, 1088.85, 20.84, 244.18)
        },
        npc = {  model = "s_m_y_ammucity_01", scenario = "WORLD_HUMAN_COP_IDLES" },
        blip = { sprite = 110, scale = 0.6, color = 0 }
    },

    -- Police armory
    ['police'] = {
        name = "Police Armory",
        items = {
            { item = 'weapon_pistol',       price = 0 },
            { item = 'weapon_stungun',      price = 0 },
            { item = 'weapon_pumpshotgun',  price = 0 },
            { item = 'weapon_smg',          price = 0 },
            { item = 'weapon_carbinerifle', price = 0, info = { 
                attachments = { 
                    { component = 'COMPONENT_AT_AR_FLSH', label = 'Flashlight', item = 'flashlight_component' }, 
                    { component = 'COMPONENT_AT_SCOPE_MEDIUM', label = '3x Scope', item = 'medscope_attachment' } 
                } 
            } },
            { item = 'weapon_nightstick',   price = 0 },
            { item = 'weapon_flashlight',   price = 0 },
            { item = 'pistol_ammo',         price = 0 },
            { item = 'smg_ammo',            price = 0 },
            { item = 'shotgun_ammo',        price = 0 },
            { item = 'rifle_ammo',          price = 0 },
            { item = 'handcuffs',           price = 0 },
            { item = 'empty_evidence_bag',  price = 0 },
            { item = 'police_stormram',     price = 0 },
            { item = 'armor',               price = 0 },
            { item = 'radio',               price = 0 },
            { item = 'heavyarmor',          price = 0 },
        },
        group = { ['police'] = 0 },
        locations = { vector4(461.8498, -981.0677, 30.6896, 91.5892) },
        npc = {  model = "mp_m_securoguard_01", scenario = "WORLD_HUMAN_COP_IDLES" },
        radius = 1.5
    }
}