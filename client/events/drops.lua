-- Server sends over new drop data
RegisterNetEvent(Config.ClientEventPrefix .. 'UpdateDrops', function(drops)
    Core.Classes.Drops.UpdateDrops(drops)
end)