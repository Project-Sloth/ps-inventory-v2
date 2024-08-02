-------------------------------------------------
--- Open Inventory
-------------------------------------------------
RegisterNetEvent(Config.ClientEventPrefix .. 'OpenInventory', function (external)
    Classes.Inventory.Open({
        external = external
    })
end)

-------------------------------------------------
--- Close Inventory
-------------------------------------------------
RegisterNetEvent(Config.ClientEventPrefix .. 'CloseInventory', function ()
    Classes.Inventory.Close()
end)

-------------------------------------------------
--- Close Inventory
-------------------------------------------------
RegisterNetEvent(Config.ClientEventPrefix .. 'Update', function (data)
    if type(data) ~= "table" then return end
    data.action = "update"
    SendNUIMessage(data)
end)

-------------------------------------------------
--- Close Inventory
-------------------------------------------------
RegisterNetEvent(Config.ClientEventPrefix .. 'MoneyChange', function (type, amount)

    if (type == "cash") then
        SendNUIMessage({
            action = "updatePlayerData",
            cash = Framework.Client.GetPlayerCash()
        })
    end
end)

-------------------------------------------------
--- Update inventory item
-------------------------------------------------
RegisterNetEvent(Config.ClientEventPrefix .. 'ItemBox', function(itemData, type, amount)
    amount = amount or 1
    SendNUIMessage({
        action = "itemBox",
        item = itemData,
        type = type,
        itemAmount = amount
    })
end)