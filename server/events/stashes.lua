-------------------------------------------------
--- Opens stash
-------------------------------------------------
RegisterNetEvent(Config.ServerEventPrefix .. 'OpenStash', function(stashId)
    local src = source
    local Player = Framework.Server.GetPlayer(src)
    local stash = Config.Stashes[stashId]

    if not stash then
        return Utilities.Log({
            type = "error",
            title = "OpenStash",
            message = "Stash[" .. stashId .. "] does not exist"
        })
    end

    local items = Classes.Inventory.LoadExternalInventory('stash', stashId)

    Classes.Inventory.OpenInventory(src, {
        type = "stash",
        id = stashId,
        name = stash.name,
        items = items
    })
end)