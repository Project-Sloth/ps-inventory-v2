-- Opens shop
RegisterNetEvent(Config.ServerEventPrefix .. 'OpenCrafting', function(craftId)
    Core.Classes.Crafting.Open(source, craftId)
end)

-- Opens shop
RegisterNetEvent(Config.ServerEventPrefix .. 'OpenCraftingByPlaceable', function(data)
    Core.Classes.Crafting.OpenByPlaceable(source, data.id)
end)