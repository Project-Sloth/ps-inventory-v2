-------------------------------------------------
--- Additional Items
--- If using a framework, the framework items
--- will be loaded first, then these will override
--- any existing items from framework
-------------------------------------------------
Config.Items = {

    -- Placeables

    crafting_bench = { 
        name = 'crafting_bench', 
        label = 'Crafting Bench', 
        weight = 25000, 
        type = 'item', 
        image = 'crafting_bench.png', 
        unique = true, 
        useable = true, 
        shouldClose = true, 
        description = 'Craft items using this bench',

        -- Needed for props that open crafting menu
        crafting = {
            recipes = { 'weapons' },
        },

        -- Needed for placeable
        placeable = {
            type = "crafting",
            prop = 'gr_prop_gr_bench_01b',
            pickupTime = 3,
            option = {
                icon = "fas fa-eye",
                label = "Open Crafting",
                event = {
                    type = "server",
                    name = 'OpenCraftingByPlaceable',
                    params = { id = 'crafting_bench' }
                }
            }
        }
    },

    -- Currency

    money = { 
        name = 'money', 
        label = 'Money', 
        weight = 0, 
        type = 'item', 
        image = 'money.png', 
        unique = false, 
        useable = false, 
        shouldClose = false
    },

    -- Identification

    id_card = { 
        name = 'id_card', 
        label = 'ID Card', 
        weight = 0, 
        type = 'item', 
        image = 'id_card.png', 
        unique = true, 
        useable = true, 
        shouldClose = false, 
        description = 'A card containing all your information to identify yourself',

        onUse = function (source, item)
            -- Do what you want here
        end
    },

    driver_license = {
        name = 'driver_license', 
        label = 'Drivers License', 
        weight = 0, 
        type = 'item', 
        image = 'driver_license.png', 
        unique = true, 
        useable = true, 
        shouldClose = false, 
        description = 'Permit to show you can drive a vehicle' ,

        onUse = function (source, item)
            -- Do what you want here
        end
    },

    -- Materials

    cloth = { 
        name = 'cloth', 
        label = 'Cloth', 
        weight = 100, 
        type = 'item', 
        image = 'cloth.png', 
        unique = false, 
        useable = false, 
        shouldClose = false, 
        description = 'Piece of cloth to craft things with' 
    },

    -- Ammo boxes
    
    pistolammo_box = { 
        name = 'pistolammo_box',
        label = 'Pistol Ammo Box',
        weight = 200,
        type = 'item',
        image = 'pistol_ammopack.png',
        unique = false,
        useable = true,
        shouldClose = true,
        description = 'Box Of Pistol Ammo'
    },

    rifleammo_box = { 
        name = 'rifleammo_box',
        label = 'Rifle Ammo Box',
        weight = 1000,
        type = 'item',
        image = 'smg_ammopack.png',
        unique = false,
        useable = true,
        shouldClose = true,
        description = 'Box Of Ammo for Rifles'
    },

    smgammo_box = { 
        name = 'smgammo_box',
        label = 'SMG Ammo Box',
        weight = 500,
        type = 'item',
        image = 'smg_ammo.png',
        unique = false,
        useable = true,
        shouldClose = true,
        description = 'Box Of Ammo for Sub Machine Guns'
    },

    shotgunammo_box = { 
        name = 'shotgunammo_box',   
        label = 'Shotgun Ammo Box', 
        weight = 500,  
        type = 'item',
        image = 'shutgun_ammopack2.png',
        unique = false,
        useable = true,
        shouldClose = true,
        description = 'Box Of Ammo for Shotguns'
    },

    mgammo_box = { 
        name = 'mgammo_box',        
        label = 'MG Ammo Box',      
        weight = 1000, 
        type = 'item', 
        image = 'ammocrate2.png',         
        unique = false, 
        useable = true, 
        shouldClose = true, 
        description = 'Box Of Ammo for Machine Guns' 
    },

    sniperammo_box = { 
        name = 'sniperammo_box',    
        label = 'Sniper Ammo Box',  
        weight = 1000,
        type = 'item',
        image = 'rifle_ammopack2.png',
        unique = false,
        useable = true,
        shouldClose = true,
        description = 'Box Of Ammo for Sniper Rifles' 
    },

    emplauncher_box = { 
        name = 'emplauncher_box',   
        label = 'EMP Ammo Box',     
        weight = 200,
        type = 'item',
        image = 'hipower_crate.png',
        unique = false,
        useable = true,
        shouldClose = true,
        description = 'Box Of Ammo for EMP Launcher' 
    },
}
