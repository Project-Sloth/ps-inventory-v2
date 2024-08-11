-------------------------------------------------
--- Setup Functions
-------------------------------------------------

-- Determine framework
Framework.Determine()

-------------------------------------------------
--- Load player inventory
-------------------------------------------------
if Framework.Client.EventPlayerLoaded then
    RegisterNetEvent(Framework.Client.EventPlayerLoaded)
    AddEventHandler (Framework.Client.EventPlayerLoaded, function()
        Core.Classes.Inventory.Load(function ()
            SendNUIMessage(InventoryInitPayload())
        end)
    end)
else
    Core.Classes.Inventory.Load(function ()
        SendNUIMessage(InventoryInitPayload())
    end)
end

-------------------------------------------
--- Open Inventory Keybind
-------------------------------------------
local keybind = lib.addKeybind({
    name = 'inventory',
    description = 'Press tab to open inventory',
    defaultKey = 'Tab',
    onReleased = function(self)

        -- Checking for external types
        local vehicleStorage = Core.Classes.Vehicles.VehicleAccessible()
        local drop = Core.Classes.Drops.IsNearDrop()
        local external = false

        if drop then
            external = drop
        elseif vehicleStorage then
            external = vehicleStorage
        end

        TriggerServerEvent(Config.ServerEventPrefix .. 'OpenInventory', external)
    end
})

-------------------------------------------
--- Keybinds for slot items
-------------------------------------------
for i = 1, 5 do
    lib.addKeybind({
        name = 'slot' .. i,
        description = 'Use item in slot ' .. i,
        defaultKey = i,
        onReleased = function(self)
            TriggerServerEvent(Config.ServerEventPrefix .. 'UseItemSlot', i)
        end
    })
end