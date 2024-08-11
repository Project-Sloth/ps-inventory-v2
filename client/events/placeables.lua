-------------------------------------------------
--- Server sends over new drop data
-------------------------------------------------
RegisterNetEvent(Config.ClientEventPrefix .. 'UpdatePlaceables', function(items)
    Core.Classes.Placeables.Update(items)
end)

-------------------------------------------------
--- Placeable item
-------------------------------------------------
RegisterNetEvent(Config.ClientEventPrefix .. 'PlaceItem', function(item)
    Core.Classes.Placeables.PlacementMode(item)
end)