-------------------------------------------------
--- Shops Setup (Runs when server starts)
-------------------------------------------------

-- Creates the shops class
Core.Classes.New("Shops")

-------------------------------------------------
--- Builds item list from shop item list
-------------------------------------------------
function Core.Classes.Shops.BuildItemList(items)
    local itemList = {}

    for slotId, item in pairs(items) do

        local itemData = Core.Classes.Inventory:GetState("Items")[item.item]
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
function Core.Classes.Shops.Open (src, shopId)
    local Player = Framework.Server.GetPlayer(src)
    local shop = Config.Shops[shopId]

    if not shop then
        return Core.Utilities.Log({
            type = "error",
            title = "OpenShop",
            message = "Shop[" .. shopId .. "] does not exist"
        })
    end

    local items = Core.Classes.Shops.BuildItemList(shop.items)

    Core.Classes.Inventory.OpenInventory(src, {
        type = "shop",
        id = shopId,
        name = shop.name,
        slots = #shop.items,
        items = items
    })
end

exports("OpenShop", Core.Classes.Shops.Open)