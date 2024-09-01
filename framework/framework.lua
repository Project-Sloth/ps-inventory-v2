------------------------------------------------------------
--                 CORE BRIDGE DETERMINATION
------------------------------------------------------------

Framework = {

    -- The core name
    CoreName = false,

    -- The core object
    Core = false,

    -- Holds all client related variables and methods
    Client = { 
        EventPlayerLoaded = false, 
        Groups = {} 
    },

    -- Check framework/your_framework/*.lua
    Server = { 
        Groups = {} 
    },

    -- Determines current framework
    Determine = function ()

        -- Validate that framework is set
        if not Config.Framework then
            Core.Utilities.Log({
                type = "error",
                title = "Framework.Determine",
                message = "Config.Framework is missing or false. (Please check Config.Framework)"
            })

            return false
        end

        -- Check that framework is valid
        local availableFrameworks = { 'qb' }
        if not Core.Utilities.TableHasValue(availableFrameworks, Config.Framework) then
            Core.Utilities.Log({
                type = "error",
                title = "Framework.Determine",
                message = "Invalid framework supplied for Config.Framework. (Please check Config.Framework)"
            })

            return false
        end

        -- Loads the bridge files based on framework and if server or not
        local frameworkFile = 'framework/' .. Config.Framework .. '/' .. (IsDuplicityVersion() and 'server' or 'client') .. '.lua'
        local res = Core.Utilities.LoadFile(frameworkFile)

        if not res then
            Core.Utilities.Log({
                type = "error",
                title = "Framework.Determine",
                message = "Unable to load framework file."
            })

            return false
        end

        Framework.Core = Framework.GetCoreObject() or nil
        return true
    end,
}