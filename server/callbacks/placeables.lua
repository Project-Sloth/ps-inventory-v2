-- Load placeables
lib.callback.register(Config.ServerEventPrefix .. 'GetPlaceables', function(source)
    return Core.Classes.Placeables.All()
end)

-- Remove placeable
lib.callback.register(Config.ServerEventPrefix .. 'RemovePlaceable', function(source, id)
    return Core.Classes.Placeables.Delete(id)
end)

-- Save placeable
lib.callback.register(Config.ServerEventPrefix .. 'SavePlaceable', function(source, data)
    return Core.Classes.Placeables.Save(data)
end)