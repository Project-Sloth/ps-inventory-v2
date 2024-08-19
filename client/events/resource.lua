-------------------------------------------
--- Resource Events
-------------------------------------------

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then

        Wait(500)

        Core.Classes.Inventory.Load(function ()
            SendNUIMessage(InventoryInitPayload())
            CreateInventoryThreads()
        end)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        Core.Classes.Player.Reset()
        Core.Classes.Crafting.Cleanup()
        Core.Classes.Inventory.Close()
        Core.Classes.Shops.Cleanup()
        Core.Classes.Drops.Cleanup()
        Core.Classes.Stashes.Cleanup()
    end
end)