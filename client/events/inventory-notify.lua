-------------------------------------------------
--- Handles syncing of inventory
-------------------------------------------------
RegisterNetEvent(Config.ClientEventPrefix .. 'InventoryNotify', function (action, item, amount)
    if action == "add" then
        Classes.InventoryNotify.AddItem(item, amount)
    elseif action == "remove" then
        Classes.InventoryNotify.RemoveItem(item, amount)
    end
end)