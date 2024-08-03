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

-------------------------------------------------
--- Open Shop
-------------------------------------------------
function Classes.Shops.Open (src, shopId)
    local Player = Framework.Server.GetPlayer(src)
    local shop = Config.Shops[shopId]

    if not shop then
        return Utilities.Log({
            type = "error",
            title = "OpenShop",
            message = "Shop[" .. shopId .. "] does not exist"
        })
    end

    local items = Classes.Shops.BuildItemList(shop.items)

    Classes.Inventory.OpenInventory(src, {
        type = "shop",
        id = shopId,
        name = shop.name,
        slots = #shop.items,
        items = items
    })
end

exports("OpenShop", Classes.Shops.Open)