Config = {

    -- Debugging
    Debugging = true,

    -- If you set this to true, it will trump settings for interact
    UseTarget = GetConvar('UseTarget', 'false') == 'true',

    -- An alert to interact with shops, stashes, etc will show
    Interact = true,

    -- Key data for interactions
    InteractKey = { Code = 38, Label = "E" },

    -- Language to use
    Language = "en",

    -- Framework
    Framework = "qb", -- "qb"

    -- Event prefixes
    ClientEventPrefix = GetCurrentResourceName() .. ":Client:",
    ServerEventPrefix = GetCurrentResourceName() .. ":Server:",

    -- Inventory images path
    InventoryImagesPath = "nui://" .. GetCurrentResourceName() .. "/nui/assets/images",

    -- Logging libraries
    Logging = {
        ['fm-logs'] = false
    },

    -- Command permissions
    CommandPermissions = {
        GiveItem        = { "admin" },
        ClearInventory  = { "admin" },
        PlayerInventory = { "admin" }
    },

    -------------------------------------------------
    --- Player Inventory Configuration
    -------------------------------------------------
    Player = {
        MaxInventoryWeight = 120000,
        MaxInventorySlots = 45,

        DatabaseSyncingThread = true, -- If disables, inventory updates on every transaction
        DatabaseSyncTime = 30 -- How often to sync database for inventories (Seconds)
    },

    -------------------------------------------------
    --- Drop Configuration
    -------------------------------------------------
    Drops = {
        MaxInventoryWeight = 120000,
        MaxInventorySlots = 41,
        ExpirationTime = 10, -- Time before drop expires (Seconds)
        Prop = 'prop_cs_heist_bag_01' -- Prop that is placed on ground for drops
    },
}