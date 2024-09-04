-- Open Inventory
RegisterNetEvent(Config.ClientEventPrefix .. 'OpenInventory', function (external)
    if source == '' then return end
    Core.Classes.Inventory.Open({
        external = external
    })
end)

-- Close Inventory
RegisterNetEvent(Config.ClientEventPrefix .. 'CloseInventory', function ()
    if source == '' then return end
    Core.Classes.Inventory.Close()
end)

-- Close Inventory
RegisterNetEvent(Config.ClientEventPrefix .. 'Update', function (data)
    if source == '' then return end
    if type(data) ~= "table" then return end
    data.action = "update"
    SendNUIMessage(data)
end)

-- Add crafting queue item
RegisterNetEvent(Config.ClientEventPrefix .. 'AddCraftingQueueItem', function (data)
    if source == '' then return end
    Core.Classes.Inventory.Update()
    data.action = "addCraftingQueueItem"
    Framework.Client.SendNUIMessage(data, true)
end)

-- Starts crafting queue timer for item in queue
RegisterNetEvent(Config.ClientEventPrefix .. 'StartCraftingQueueTimer', function (id)
    if source == '' then return end
    Framework.Client.SendNUIMessage({
        action = "startCraftingQueueTimer",
        id = id
    }, true)
end)

-- Remove crafting queue item
RegisterNetEvent(Config.ClientEventPrefix .. 'RemoveCraftingQueueItem', function (id)
    if source == '' then return end
    Framework.Client.SendNUIMessage({
        action = "removeCraftingQueueItem",
        id = id
    }, true)
end)