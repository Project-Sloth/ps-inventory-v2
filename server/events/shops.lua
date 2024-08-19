-- Opens shop
RegisterNetEvent(Config.ServerEventPrefix .. 'OpenShop', function(shopId)
    Core.Classes.Shops.Open(source, shopId)
end)