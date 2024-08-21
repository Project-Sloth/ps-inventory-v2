if not Core then Core = {} end

Core.Language = {

    State = {
        AssignedLanguage = "en",
        Locales = {}
    }
}

-- Sets assigned language
---@param language string
---@return table
Core.Language.SetLanguage = function(language)
    Core.Language.State.AssignedLanguage = language

    Core.Utilities.Log({
        title = "Core.Language",
        message = "Language has been set to " .. language
    })

    return Core.Language
end

-- Loads the locale file
---@return boolean
Core.Language.LoadLocales = function ()
    local localesFile = LoadResourceFile(GetCurrentResourceName(), "./locales/" .. Core.Language.State.AssignedLanguage .. ".json")
    
    if localesFile then
        local localesDecoded = json.decode(localesFile)
        Core.Language.State.Locales = localesDecoded
        return true
    end

    Core.Utilities.Log({
        type = "error",
        title = "Core.Language",
        message = "Unable to find locales for language: " .. Core.Language.State.AssignedLanguage
    })

    return false
end

-- Returns locales set
---@return table
Core.Language.GetLocales = function ()
    return Core.Language.State.Locales
end

-- Sets locales that are passed to state
---@param locales table
---@return boolean
Core.Language.SetLocales = function (locales)
    if type(locales) ~= "table" then
        Core.Utilities.Log({
            type = "error",
            title = "Core.Language",
            message = "SetLocales requires parameter 1 to be of type `table`"
        })

        return false
    end

    Core.Language.State.Locales = locales
    return true
end

-- Gets a locale from the table and merges the tags if applicable
---@param key string
---@param mergeTags table
---@param return boolean|string
Core.Language.Locale = function (key, mergeTags)
    local locale = ""

    if not Core.Language.State.Locales[key] then
        Core.Utilities.Log({
            type = "error",
            title = "Core.Language",
            message = 'Unable to find locale.' .. key
        })

        return false
    end

    locale = Core.Language.State.Locales[key]

    if mergeTags then
        if type(mergeTags) == "table" then
            for k, v in pairs(mergeTags) do
                locale = locale:gsub("{{" .. k .. "}}", v)
            end
        end
    end

    return locale
end

-- Handles a string without validating mergeTags against locale keys
---@param message string
---@param mergeTags table
---@return string
Core.Language.ProcessString = function (message, mergeTags)
    for k, v in pairs(mergeTags) do
        if type(v) == "table" then
            message = Core.Language.ProcessString(message, v)
        else
            message = message:gsub("{{" .. string.lower(k) .. "}}", v)
        end
    end

    return message
end