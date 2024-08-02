-------------------------------------------------
--- Thread for clearing expired drops
-------------------------------------------------

-- Only runs if Config.Player.DatabaseSyncingThread is true
if Config.Player.DatabaseSyncingThread then

    Utilities.Log({
        title = "DatabaseSyncing",
        message = "Database syncing is enabled, player inventories will be synced every " .. Config.Player.DatabaseSyncTime .. " seconds."
    })

    CreateThread(function ()
        while true do
            Wait(Config.Player.DatabaseSyncTime * 1000)
            Classes.Inventory.SyncDatabase()
        end
    end)
end