-- Opens vending
RegisterNetEvent(Config.ServerEventPrefix .. 'OpenVending', function()
    Core.Classes.Shops.Open(source, 'vending')
end)