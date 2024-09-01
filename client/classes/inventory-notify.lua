-------------------------------------------------
--- Inventory Notify Setup
-------------------------------------------------

-- Creates the inventory notify class
Core.Classes.New("InventoryNotify")

-- Adds item in NUI
---@param item table
---@param amount number
function Core.Classes.InventoryNotify.AddItem(item, amount)
    SendNUIMessage({
        action = "notify",
        process = "add",
        item = item,
        amount = amount
    })

    if item.name:lower():find('ammo') then
        Core.Classes.Weapon.UpdatePedAmmo()
    end
end

-- Removes item in NUI
---@param item table
---@param amount number
function Core.Classes.InventoryNotify.RemoveItem(item, amount)
    SendNUIMessage({
        action = "notify",
        process = "remove",
        item = item,
        amount = amount
    })
end