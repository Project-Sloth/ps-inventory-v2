-- Open Inventory
RegisterNetEvent(Config.ClientEventPrefix .. 'OpenInventory', function (external)
    Core.Classes.Inventory.Open({
        external = external
    })
end)

-- Close Inventory
RegisterNetEvent(Config.ClientEventPrefix .. 'CloseInventory', function ()
    Core.Classes.Inventory.Close()
end)

-- Close Inventory
RegisterNetEvent(Config.ClientEventPrefix .. 'Update', function (data)
    if type(data) ~= "table" then return end
    data.action = "update"
    SendNUIMessage(data)
end)

-- Add crafting queue item
RegisterNetEvent(Config.ClientEventPrefix .. 'AddCraftingQueueItem', function (data)
    Core.Classes.Inventory.Update()
    data.action = "addCraftingQueueItem"
    Framework.Client.SendNUIMessage(data, true)
end)

-- Starts crafting queue timer for item in queue
RegisterNetEvent(Config.ClientEventPrefix .. 'StartCraftingQueueTimer', function (id)
    Framework.Client.SendNUIMessage({
        action = "startCraftingQueueTimer",
        id = id
    }, true)
end)

-- Remove crafting queue item
RegisterNetEvent(Config.ClientEventPrefix .. 'RemoveCraftingQueueItem', function (id)
    Framework.Client.SendNUIMessage({
        action = "removeCraftingQueueItem",
        id = id
    }, true)
end)