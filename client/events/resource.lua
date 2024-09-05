-------------------------------------------
--- Resource Events
-------------------------------------------

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Core.Classes.Inventory.Load(function (items)
            InventoryLoaded(items)
        end)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        Core.SpawnManager.OnResourceStop()
        Core.Classes.Player.Reset()
        Core.Classes.Crafting.Cleanup()
        Core.Classes.Inventory.Close()
        Core.Classes.Shops.Cleanup()
        Core.Classes.Drops.Cleanup()
        Core.Classes.Stashes.Cleanup()
    end
end)