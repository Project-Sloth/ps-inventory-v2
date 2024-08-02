------------------------------------------------------------
--                 CORE BRIDGE DETERMINATION
------------------------------------------------------------

Framework = {

    -- The core name
    CoreName = "Standalone",

    -- The core object
    Core = false,

    -- Holds all client related variables and methods
    Client = { EventPlayerLoaded = false },

    -- Check bridge/your_framework/*.lua
    Server = { },

    -- Determines current framework
    Determine = function ()
        -- Loads the bridge files based on framework and if server or not
        if Config.Framework then
            Utilities.LoadFile(lib, 'bridge.' .. Config.Framework .. '.' .. (IsDuplicityVersion() and 'server' or 'client'))
        end

        Framework.Core = Config.Framework ~= 'standalone' and Framework.GetCoreObject() or nil
    end,
}