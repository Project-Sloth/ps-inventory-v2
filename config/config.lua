Config = {

    -- Debugging
    Debugging = true,

    -- Debug logging
    Logging = {
        ['fm-logs'] = false
    },

    -- If you set this to true, it will trump settings for interact
    UseTarget = GetConvar('UseTarget', 'false') == 'true',
    
    -- Target options
    Target = "qb", -- "qb", "ox"
    TargetDebugging = false, -- Ox shows box zones in red

    -- Notify options
    Notify = 'ox', -- qb or ox

    -- Progressbar Options
    Progressbar = 'qb', -- options: qb, oxbar, oxcircle
    -- An alert to interact with shops, stashes, etc will show
    Interact = true,

    -- Key data for interactions
    InteractKey = { Code = 38, Label = "E" },

    -- Language to use
    Language = "en",

    -- Framework
    Framework = "qb", -- "qb"
    
    -- QB specific
    OldCore = false, -- If you are using an older version of QB Core
    ConvertInventories = false, -- Convert old QB core inventories
    RemoveOldCoreInventories = false, -- Remove old core inventories during conversion

    -- Will attempt to pull defined items from framework (Example: QBShared.items)
    LoadFrameworkInventoryItems = true,

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
        Player   = { MaxWeight = 120000,  MaxSlots = 45 },
        Drop     = { MaxWeight = 120000,  MaxSlots = 41 },
        Stash    = { MaxWeight = 120000,  MaxSlots = 41 },
        Glovebox = { MaxWeight = 20000,   MaxSlots = 5 },
        Trunk    = { MaxWeight = 70000,   MaxSlots = 10 }
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
        ExpirationTime = 120, -- Time before drop expires (Seconds)
        Radius = 4, -- Radius of access to drop
        Prop = 'bkr_prop_duffel_bag_01a' -- Prop that is placed on ground for drops
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

    -------------------------------------------------
    --- Placeables Configuration
    -------------------------------------------------
    Placeables = {

        -- If disabled, placeables can not be placed
        Enabled = true,

        -- Radius for Interaction or Target
        Radius = 1.5, 

        -- How many seconds to pickup
        PickupTime = 1,

        -- Progress configurables
        PickupDisablesMovement = true,
        PickupDisablesCarMovement = true,
        PickupDisablesCombat = true,

        -- Placeables placement mode configuration
        ItemPlacementModeRadius = 10.0,
        MinZOffset = -2.0,
        MaxZOffset = 2.0
    },

    -------------------------------------------------
    --- Themes Configuration
    --- Available variables:
    --- color, shadowColor, borderRadius
    -------------------------------------------------
    Themes = {
        ['ps'] = {
            color = "#beda17",
            shadowColor = "rgba(190, 218, 23, 0.6)",
            borderRadius = 5
        },

        ['sun-flower'] = {
            color = "#f1c40f",
            shadowColor = "rgba(241, 196, 15, 0.6)",
            borderRadius = 5
        },

        ['red'] = {
            color = "#e74c3c",
            shadowColor = "rgba(231, 76, 60, 0.6)",
            borderRadius = 5
        },

        ['emrald'] = {
            color = "#2ecc71",
            shadowColor = "rgba(46, 204, 116, 0.6)",
            borderRadius = 5
        },
    }
}
