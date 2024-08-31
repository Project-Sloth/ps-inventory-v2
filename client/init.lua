-- Determine language
local LanguageLocales = lib.callback.await(Config.ServerEventPrefix .. 'RetrieveLocales', false)
if LanguageLocales then
    Core.Language.SetLanguage(Config.Language).SetLocales(LanguageLocales)
end

-- Determine framework
Framework.Determine()

-- Load player inventory
if Framework.Client.EventPlayerLoaded then
    RegisterNetEvent(Framework.Client.EventPlayerLoaded)
    AddEventHandler (Framework.Client.EventPlayerLoaded, function()
        Core.Classes.Inventory.Load(function (items)
            InventoryLoaded(items)
        end)
    end)
else
    Core.Classes.Inventory.Load(function (items)
        InventoryLoaded(items)
    end)
end

-- Reload weapon
lib.addKeybind({
    name = 'reload_weapon',
    description = 'Reload weapon',
    defaultKey = "r",
    onPressed = function()
        Core.Classes.Weapon.UpdateAmmo(true)
    end
})

-- Toggle hotbar keybind
lib.addKeybind({
    name = 'hotbar',
    description = 'Toggle hotbar',
    defaultKey = "Z",
    onPressed = function()
        SendNUIMessage({ action = 'toggleHotbar' })
    end
})

-- Open Inventory Keybind
lib.addKeybind({
    name = 'inventory',
    description = 'Open inventory',
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

-- Keybinds for slot items
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