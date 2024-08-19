-- Opens player inventory
RegisterServerEvent(Config.ServerEventPrefix .. 'OpenInventory', function (external)
    local src = source

    if external then
        return Core.Classes.Inventory.LoadExternalInventoryAndOpen(src, external.type, external.id, external)
    end

    Core.Classes.Inventory.OpenInventory(src)
end)

-- Closes player inventory
RegisterServerEvent(Config.ServerEventPrefix .. 'CloseInventory', function ()
    Core.Classes.Inventory.CloseInventory(source)
end)

-- Uses Item Slot
RegisterNetEvent(Config.ServerEventPrefix .. 'UseItemSlot', function(slot)
    local src = source
    local itemData = Core.Classes.Inventory.GetSlot(src, slot)
    if not itemData then return false end
    Core.Classes.Inventory.ValidateAndUseItem(src, itemData)
end)

-- Uses Item
RegisterNetEvent(Config.ServerEventPrefix .. 'UseItem', function(inventory, item)
    local src = source
    local itemData = Core.Classes.Inventory.GetSlot(src, item.slot)
    if not itemData then return false end
    Core.Classes.Inventory.ValidateAndUseItem(src, itemData)
end)
