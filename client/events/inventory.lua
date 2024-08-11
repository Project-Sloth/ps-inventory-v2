-------------------------------------------------
--- Open Inventory
-------------------------------------------------
RegisterNetEvent(Config.ClientEventPrefix .. 'OpenInventory', function (external)
    Core.Classes.Inventory.Open({
        external = external
    })
end)

-------------------------------------------------
--- Close Inventory
-------------------------------------------------
RegisterNetEvent(Config.ClientEventPrefix .. 'CloseInventory', function ()
    Core.Classes.Inventory.Close()
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
--- Add crafting queue item
-------------------------------------------------
RegisterNetEvent(Config.ClientEventPrefix .. 'AddCraftingQueueItem', function (data)
    Core.Classes.Inventory.Update()
    data.action = "addCraftingQueueItem"
    SendNUIMessage(data)
end)

-------------------------------------------------
--- Remove crafting queue item
-------------------------------------------------
RegisterNetEvent(Config.ClientEventPrefix .. 'RemoveCraftingQueueItem', function (id)
    Core.Classes.Inventory.Update()
    SendNUIMessage({
        action = "removeCraftingQueueItem",
        id = id
    })
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