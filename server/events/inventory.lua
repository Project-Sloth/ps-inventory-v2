-------------------------------------------------
--- Opens player inventory
-------------------------------------------------
RegisterServerEvent(Config.ServerEventPrefix .. 'OpenInventory', function (external)
    local src = source

    if external then
        local Player = Framework.Server.GetPlayer(src)
        local items = Classes.Inventory.LoadExternalInventory(external.type, external.id)
        external.items = items

        if external.id:find('glovebox') then
            external.slots = Config.Vehicles.MaxSlots
        end

        -- Item check for drops
        if external.type == "drop" and Utilities.TableLength(external.items) == 0 then
            external = false
        end
    end

    Classes.Inventory.OpenInventory(src, external)
end)

-------------------------------------------------
--- Closes player inventory
-------------------------------------------------
RegisterServerEvent(Config.ServerEventPrefix .. 'CloseInventory', function ()
    Classes.Inventory.CloseInventory(source)
end)

-------------------------------------------------
--- Uses Item Slot
-------------------------------------------------
RegisterNetEvent(Config.ServerEventPrefix .. 'UseItemSlot', function(slot)
    local src = source
    local itemData = Classes.Inventory.GetSlot(src, slot)
    if not itemData then return false end
    Classes.Inventory.ValidateAndUseItem(src, itemData)
end)

-------------------------------------------------
--- Uses Item
-------------------------------------------------
RegisterNetEvent(Config.ServerEventPrefix .. 'UseItem', function(inventory, item)
    local src = source
    local itemData = Classes.Inventory.GetSlot(src, item.slot)
    Classes.Inventory.ValidateAndUseItem(src, itemData)
end)
