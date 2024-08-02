-------------------------------------------------
--- Shops Setup (Runs when server starts)
-------------------------------------------------

-- Creates the shops class
Classes.New("Shops")

-------------------------------------------------
--- Builds item list from shop item list
-------------------------------------------------
function Classes.Shops.BuildItemList(items)
    local itemList = {}

    for slotId, item in pairs(items) do

        local itemData = Classes.Inventory:GetState("Items")[item.item]
        if itemData then
            itemData.price = item.price
            itemData.slot = slotId
            itemData.amount = 1
            table.insert(itemList, itemData)
        end
    end

    return itemList
end