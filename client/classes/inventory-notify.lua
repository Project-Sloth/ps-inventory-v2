-------------------------------------------------
--- Inventory Notify Setup
-------------------------------------------------

-- Creates the inventory notify class
Core.Classes.New("InventoryNotify")

-- Adds item in NUI
function Core.Classes.InventoryNotify.AddItem(item, amount)
    SendNUIMessage({
        action = "notify",
        process = "add",
        slot = slot,
        item = item,
        amount = amount
    })
end

-- Removes item in NUI
function Core.Classes.InventoryNotify.RemoveItem(item, amount)
    SendNUIMessage({
        action = "notify",
        process = "remove",
        slot = slot,
        item = item,
        amount = amount
    })
end