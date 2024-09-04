-- Load the language locales
Core.Language.SetLanguage(Config.Language).LoadLocales()

-- Determine the framework
local determined = Framework.Determine()

-- Determine framework
if not determined then
    Core.Utilities.Log({
        type = "error",
        title = "Framework.Determine",
        message = "Unable to determine inventory framework."
    })
else
   -- Return locales from language state
    lib.callback.register(Config.ServerEventPrefix .. 'RetrieveLocales', function ()
        return Core.Language.State.Locales
    end)

    -- Load the inventory items
    Core.Classes.Inventory.Load(true)

    -- Process crafting queue
    Core.Crons.Register('Crafting.Queue', 1, function ()
        Core.Classes.Crafting.ProcessQueue()
    end, false)

    -- Clear expired drops
    Core.Crons.Register('Drops.ClearExpired', Config.Drops.ExpirationTime, function ()
        Core.Classes.Drops.ClearExpired()
    end, true)

    -- Only runs if Config.Player.DatabaseSyncingThread is true
    if Config.Player.DatabaseSyncingThread then

        -- Sync inventories to database
        Core.Crons.Register('Inventory.DatabaseSyncing', Config.Player.DatabaseSyncTime, function ()
            Core.Classes.Inventory.SyncDatabase()
        end, true)
    end

    -- Starts the cron processor
    Core.Crons.StartProcessor()

    -- Resource stop event
    AddEventHandler('onServerResourceStop', function(resource)
        if resource == GetCurrentResourceName() then

            Core.Utilities.Log({
                type = "warning",
                title = "Inventory Stopped",
                message = "Syncing database for all online players"
            })

            Core.Classes.Inventory.SyncDatabase()
        end
    end) 
end