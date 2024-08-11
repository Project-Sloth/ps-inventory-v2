Config = {

    -- Debugging
    Debugging = true,

    -- Debug logging
    Logging = {

        -- Logging to console
        Console = {
            Drops = false,
            Syncing = false,
            Crafting = false
        },

        -- Logging to providers
        Remote = {
            Drops = false,
            Syncing = false,
            Crafting = false
        },

        -- Remove logging configuration
        Providers = {
            ['fm-logs'] = false
        }
    },

    -- If you set this to true, it will trump settings for interact
    UseTarget = GetConvar('UseTarget', 'false') == 'true',

    Target = "qb", -- "qb", "ox"
    TargetDebugging = false, -- Ox shows box zones in red

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

    -------------------------------------------------
    --- Vending Configuration
    -------------------------------------------------
    Vending = {

        Props = {
            'prop_vend_soda_01',
            'prop_vend_soda_02',
            'prop_vend_water_01',
            'prop_vend_coffe_01',
        },

        Items = {
            { item = 'kurkakola',    price = 4 },
            { item = 'water_bottle', price = 4 },
        }
    },

    Placeables = {
        ItemPlacementModeRadius = 10.0,
        minZOffset = -2.0,
        maxZOffset = 2.0
    }
}