-- Craft item
lib.callback.register(Config.ServerEventPrefix .. "CraftItem", function (source, data)
    local canCraftItem = Core.Classes.Crafting.CanCraftItem(source, data)
    if not canCraftItem then return { success = false, message = "You are missing some materials" } end

    -- Weight check
    if not Core.Classes.Inventory.CanCarryItem(source, canCraftItem.item.name, canCraftItem.amount) then
        return { success = false, message = "You do not have enough weight" }
    end

    return Core.Classes.Crafting.QueueItem(source, canCraftItem)
end)