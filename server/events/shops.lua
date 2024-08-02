-------------------------------------------------
--- Opens shop
-------------------------------------------------
RegisterNetEvent(Config.ServerEventPrefix .. 'OpenShop', function(shopId)
    local src = source
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
end)