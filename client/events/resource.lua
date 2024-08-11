-------------------------------------------
--- Resource Events
-------------------------------------------
AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then

        Wait(500)

        Core.Classes.Inventory.Load(function ()
            SendNUIMessage(InventoryInitPayload())
        end)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        Core.Classes.Crafting.Cleanup()
        Core.Classes.Inventory.Close()
        Core.Classes.Shops.Cleanup()
        Core.Classes.Drops.Cleanup()
    end
end)