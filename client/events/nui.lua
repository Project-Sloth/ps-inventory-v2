-------------------------------------------------
--- Closes the UI
-------------------------------------------------
RegisterNUICallback('close', function(_, cb)
    Classes.Inventory.Close()
    cb({ status = true })
end)

-------------------------------------------------
--- Sends of the moving of an item
-------------------------------------------------
RegisterNUICallback('move', function(data, cb)
    local res = Classes.Inventory.Move(data)
    cb(res)
end)

-------------------------------------------------
--- Drops item
-------------------------------------------------
RegisterNUICallback('drop', function(data, cb)
    local res = Classes.Inventory.Drop(data)
    cb(res)
end)

-------------------------------------------------
--- Drops item
-------------------------------------------------
RegisterNUICallback('updateExternalState', function(data, cb)

    -- Only update if provided
    if data.external then
        Classes.Inventory.UpdateExternalState(data.external)
    end

    cb({ success = true })
end)

-------------------------------------------------
--- Calls method for buying an item
-------------------------------------------------
RegisterNUICallback('buy', function(data, cb)
    local res = Classes.Shops.Buy(data)
    cb(res)
end)

-------------------------------------------------
--- Calls method for using an item
-------------------------------------------------
RegisterNUICallback("useItem", function(data, cb)
    TriggerServerEvent(Config.ServerEventPrefix .. 'UseItem', data.inventory, data.item)
    cb({ status = true })
end)