-------------------------------------------------
--- Opens shop
-------------------------------------------------
RegisterNetEvent(Config.ServerEventPrefix .. 'OpenShop', function(shopId)
    Classes.Shops.Open(source, shopId)
end)