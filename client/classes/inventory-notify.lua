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