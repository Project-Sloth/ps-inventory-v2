-- Buy item from a shop
lib.callback.register(Config.ServerEventPrefix .. "Buy", function (source, data)
    return Core.Classes.Shops.BuyItem(source, data)
end)