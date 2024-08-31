-- Get Player Inventory Preferences Callback
lib.callback.register(Config.ServerEventPrefix .. 'GetInventoryPreferences', function(source)
    return Core.Classes.Player.GetInventoryPreferences(source)
end)

-- Save Player Inventory Preferences Callback
lib.callback.register(Config.ServerEventPrefix .. 'SaveInventoryPreferences', function(source, data)
    return Core.Classes.Player.SaveInventoryPreferences(source, data)
end)

-- Get Player Inventory Callback
lib.callback.register(Config.ServerEventPrefix .. 'GetPlayerInventory', function(source)
    return Core.Classes.Inventory.GetPlayerInventory(source)
end)

-- Save Player Inventory Callback
lib.callback.register(Config.ServerEventPrefix .. 'SavePlayerInventory', function(source)
    return Core.Classes.Inventory.SavePlayerInventory(source)
end)

-- Remove item
lib.callback.register(Config.ServerEventPrefix .. 'RemoveItem', function(source, item)
    return Core.Classes.Inventory.RemoveItem(source, item.name, item.amount, item.slot)
end)

-- Add item
lib.callback.register(Config.ServerEventPrefix .. 'AddItem', function(source, item)
    return Core.Classes.Inventory.AddItem(source, item.name, item.amount)
end)

-- Move inventory item callback
lib.callback.register(Config.ServerEventPrefix .. 'Move', function (source, data)
    return Core.Classes.Inventory.Move(source, data)
end)

-- Split item callback
lib.callback.register(Config.ServerEventPrefix .. 'Split', function (source, data)
    return Core.Classes.Inventory.Split(source, data)
end)

-- Give item callback
lib.callback.register(Config.ServerEventPrefix .. 'Give', function (source, data)
    return Core.Classes.Inventory.Give(source, data)
end)

-- Drop item callback
lib.callback.register(Config.ServerEventPrefix .. 'Drop', function (source, data)
    return Core.Classes.Drops.Create(source, data)
end)

-- Event callback
lib.callback.register(Config.ServerEventPrefix .. 'Event', function (source, data)
    if data.event == "open" then
        Player(source).state.inventoryBusy = true
    end

    if data.event == "close" then
        Player(source).state.inventoryBusy = false
    end
end)