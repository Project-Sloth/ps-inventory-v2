-- Handles syncing of inventory
RegisterNetEvent(Config.ClientEventPrefix .. 'InventoryNotify', function (action, item, amount)
    if source == '' then return end
    
    if action == "add" then
        Core.Classes.InventoryNotify.AddItem(item, amount)
    elseif action == "remove" then
        Core.Classes.InventoryNotify.RemoveItem(item, amount)
    end

    -- Update if not open to keep hotbar up to date
    if Core.Classes.Inventory:GetState('IsOpen') == false then
        Core.Classes.Inventory.Update()
    end
end)