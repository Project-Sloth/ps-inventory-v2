-------------------------------------------------
--- Server sends over new drop data
-------------------------------------------------
RegisterNetEvent(Config.ClientEventPrefix .. 'UpdateDrops', function(drops)
    Classes.Drops.UpdateDrops(drops)
end)