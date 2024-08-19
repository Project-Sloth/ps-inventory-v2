-------------------------------------------------
--- Additional Items
--- If using a framework, the framework items
--- will be loaded first, then these will override
--- any existing items from framework
-------------------------------------------------
Config.Items = {

    crafting_bench = { 
        name = 'crafting_bench', 
        label = 'Crafting Bench', 
        weight = 5000, 
        type = 'item', 
        image = 'crafting_bench.png', 
        unique = true, 
        useable = true, 
        shouldClose = true, 
        description = 'Craft items using this bench',

        -- Example of usage on item
        onUse = function (source, item)
            item.placeableType = 'crafting'
            item.recipes = { 'weapons' }
            item.prop = 'gr_prop_gr_bench_01b'
            item.eventType = "server"
            item.eventName = Config.ServerEventPrefix .. 'OpenCraftingByPlaceable'
            item.interactType = "crafting"
            item.eventParams = { id = item }
            TriggerClientEvent(Config.ClientEventPrefix .. 'PlaceItem', source, item)
        end
    },

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
}