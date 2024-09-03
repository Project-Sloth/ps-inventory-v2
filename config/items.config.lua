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
}