-- Opens stash
RegisterNetEvent(Config.ServerEventPrefix .. 'OpenStash', function(stashId)
    Core.Classes.Inventory.OpenStash(source, stashId)
end)