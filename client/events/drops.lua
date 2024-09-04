-- Server sends over new drop data
RegisterNetEvent(Config.ClientEventPrefix .. 'UpdateDrops', function(drops)
    if source == '' then return end
    Core.Classes.Drops.UpdateDrops(drops)
end)