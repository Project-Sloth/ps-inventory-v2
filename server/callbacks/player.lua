-------------------------------------------------
--- Get Player Inventory Callback
-------------------------------------------------
lib.callback.register(Config.ServerEventPrefix .. 'GetPlayerInventory', function(source)
    return Classes.Inventory.GetPlayerInventory(source)
end)

-------------------------------------------------
--- Save Player Inventory Callback
-------------------------------------------------
lib.callback.register(Config.ServerEventPrefix .. 'SavePlayerInventory', function(source)
    return Classes.Inventory.SavePlayerInventory(source)
end)

-------------------------------------------------
--- Move inventory item callback
-------------------------------------------------
lib.callback.register(Config.ServerEventPrefix .. 'Move', function (source, data)
    return Classes.Inventory.Move(source, data)
end)

-------------------------------------------------
--- Drop item callback
-------------------------------------------------
lib.callback.register(Config.ServerEventPrefix .. 'Drop', function (source, data)
    return Classes.Drops.Create(source, data)
end)

-------------------------------------------------
--- Event callback
-------------------------------------------------
lib.callback.register(Config.ServerEventPrefix .. 'Event', function (source, data)
    if data.event == "open" then
        Player(source).state.inventoryBusy = true
    end

    if data.event == "close" then
        Player(source).state.inventoryBusy = false
    end
end)