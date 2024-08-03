-------------------------------------------------
--- Opens stash
-------------------------------------------------
RegisterNetEvent(Config.ServerEventPrefix .. 'OpenStash', function(stashId)
    Classes.Inventory.OpenStash(source, stashId)
end)