-------------------------------------------
--- Resource Events
-------------------------------------------
AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then

        Wait(500)

        Classes.Inventory.Load(function ()
            SendNUIMessage(InventoryInitPayload())
        end)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        Classes.Shops.Cleanup()
        Classes.Drops.Cleanup()
    end
end)