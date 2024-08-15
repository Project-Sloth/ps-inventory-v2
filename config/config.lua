Config = {

    -- Debugging
    Debugging = true,

    -- Debug logging
    Logging = {
        ['fm-logs'] = false
    },

    -- If you set this to true, it will trump settings for interact
    UseTarget = GetConvar('UseTarget', 'false') == 'true',

    Target = "ox", -- "qb", "ox"
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
    --- Default weight and slots
    -------------------------------------------------
    Inventories = {

        Player = {
            MaxWeight = 120000,
            MaxSlots = 45
        },

        Drop = {
            MaxWeight = 120000,
            MaxSlots = 41
        },

        Stash = {
            MaxWeight = 120000,
            MaxSlots = 41
        },
        
        Glovebox = {
            MaxWeight = 20000,
            MaxSlots = 5
        },

        Trunk = {
            MaxWeight = 70000,
            MaxSlots = 10
        }
    },

    -------------------------------------------------
    --- Player Inventory Configuration
    -------------------------------------------------
    Player = {
        DatabaseSyncingThread = true, -- If disables, inventory updates on every transaction
        DatabaseSyncTime = 30 -- How often to sync database for inventories (Seconds)
    },

    -------------------------------------------------
    --- Drop Configuration
    -------------------------------------------------
    Drops = {
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