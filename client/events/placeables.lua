-- Server sends over new drop data
RegisterNetEvent(Config.ClientEventPrefix .. 'UpdatePlaceables', function(items)
    if Config.Placeables.Enabled then
        Core.Classes.Placeables.Update(items)
    end
end)

-- Placeable item
RegisterNetEvent(Config.ClientEventPrefix .. 'PlaceItem', function(item)
    if Config.Placeables.Enabled then
        Core.Classes.Placeables.PlacementMode(item)
    end
end)