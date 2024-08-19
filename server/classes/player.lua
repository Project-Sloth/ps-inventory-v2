Core.Classes.New("Player", {
    defaultPreferences = {
        theme = 'ps'
    }
})

-- Gets the inventory preferences for a player
---@param src number
function Core.Classes.Player.GetInventoryPreferences (src)
    local PlayerIdentifier = Framework.Server.GetPlayerIdentifier(src)

    -- If no player identifer, return default preferences
    if not PlayerIdentifier then
        return Core.Classes.Player:GetState('defaultPreferences')
    end

    -- Get player preferences
    local row = MySQL.single.await("SELECT * FROM inventory_preferences WHERE identifier = ?", { PlayerIdentifier })
    if not row then
        MySQL.insert.await('INSERT INTO inventory_preferences(identifier, preferences) VALUES(?, ?)', {
            PlayerIdentifier,
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
    if not data.theme then return false end
    if not Config.Themes[data.theme] then return false end

    local PlayerIdentifier = Framework.Server.GetPlayerIdentifier(src)
    if not PlayerIdentifier then return false end
    
    local res = MySQL.update.await('UPDATE inventory_preferences SET preferences = ? WHERE identifier = ?', {
        json.encode(data),
        PlayerIdentifier
    })

    if not res then return false end
    return true
end