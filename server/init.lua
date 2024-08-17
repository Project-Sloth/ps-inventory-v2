-------------------------------------------------
--- Version and status
-------------------------------------------------

local version = GetResourceMetadata(GetCurrentResourceName(), 'version')

print('--------------------------------------------------')
print('|                                                |')
print('|                   PS INVENTORY                 |')
print('|                     STARTED                    |')
print('|                  VERSION ' .. version .. '                 |')
print('|                                                |')
print('--------------------------------------------------')

-------------------------------------------------
--- Setup Functions
-------------------------------------------------

-- Determine framework
Framework.Determine()

-- Load the inventory items
Core.Classes.Inventory:Load(true)

-------------------------------------------------
--- Cron jobs
-------------------------------------------------

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