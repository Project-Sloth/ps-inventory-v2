Core.Classes.New("Player", {
    defaultPreferences = {
        theme = 'ps'
    }
})

-- Gets the inventory preferences for a player
---@param src number
function Core.Classes.Player.GetInventoryPreferences (src)
    local playerIdentifier = Framework.Server.GetPlayerIdentifier(src)

    -- If no player identifer, return default preferences
    if not playerIdentifier then
        return Core.Classes.Player:GetState('defaultPreferences')
    end

    -- Get player preferences
    local row = MySQL.single.await("SELECT * FROM inventory_preferences WHERE identifier = ?", { playerIdentifier })
    if not row then
        MySQL.insert.await('INSERT INTO inventory_preferences(identifier, preferences) VALUES(?, ?)', {
            playerIdentifier,
            json.encode(Core.Classes.Player:GetState('defaultPreferences'))
        })

        return Core.Classes.Player:GetState('defaultPreferences')
    end

    -- Return database preferences
    return json.decode(row.preferences)
end

-- Saves player inventory preferences
---@param src number
---@param data table
---@return boolean
function Core.Classes.Player.SaveInventoryPreferences (src, data)
    if not data.theme then 
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Player.SaveInventoryPreferences",
            message = "Incorrect payload sent"
        })

        return false 
    end

    if not Config.Themes[data.theme] then 
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Player.SaveInventoryPreferences",
            message = "Unable to save, theme[" .. data.theme .. "] does not exist in configuration"
        })

        return false 
    end

    local playerIdentifier = Framework.Server.GetPlayerIdentifier(src)
    if not playerIdentifier then 
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Player.SaveInventoryPreferences",
            message = "Unable to retrieve player identifier"
        })

        return false 
    end
    
    local res = MySQL.update.await('UPDATE inventory_preferences SET preferences = ? WHERE identifier = ?', {
        json.encode(data),
        playerIdentifier
    })

    if not res then 
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Player.SaveInventoryPreferences",
            message = "An error occurred during the update query"
        })

        return false 
    end

    return true
end