-------------------------------------------------
--- FRAMEWORK FUNCTION OVERRIDES
--- These files are loaded based on the value set
--- for Config.Framework
-------------------------------------------------
-- Get core object
Framework.GetCoreObject = function()
    Framework.CoreName = "qb"
    Framework.Core = exports['qb-core']:GetCoreObject()
    Framework.Client.EventPlayerLoaded = "QBCore:Client:OnPlayerLoaded"
    return Framework.Core
end

-- Get player name
Framework.Client.GetPlayerName = function()
    -- Attempt to get Player table
    local player = Framework.Core.Functions.GetPlayerData()

    -- If unavailable, return server player name
    if player == nil then
        return GetPlayerName(source)
    end

    -- Return player name
    return player.charinfo.firstname .. " " .. player.charinfo.lastname
end

-- Get player identifier
---@return string
Framework.Client.GetPlayerIdentifier = function()
    local player = Framework.Core.Functions.GetPlayerData()
    return player.citizenid
end

-- Get player cash
---@return number
Framework.Client.GetPlayerCash = function()
    local player = Framework.Core.Functions.GetPlayerData()
    return player.money.cash
end

-- Can open inventory
---@return boolean
Framework.Client.CanOpenInventory = function()
    local playerData = Framework.Core.Functions.GetPlayerData()
    if not playerData then
        return false
    end

    if playerData.metadata["isdead"] or playerData.metadata["inlaststand"] or playerData.metadata["ishandcuffed"] or
        IsPauseMenuActive() then
        return false
    end

    return true
end

-- Has Group
---@param group table
Framework.Client.HasGroup = function(group)
    local playerData = Framework.Core.Functions.GetPlayerData()
    if not playerData.job then
        return false
    end

    local groups = {
        [playerData.job.name] = playerData.job.grade.level,
        [playerData.gang.name] = playerData.gang.grade.level
    }

    if type(group) == 'table' then
        for name, rank in pairs(group) do
            local groupRank = groups[name]
            if groupRank and groupRank >= (rank or 0) then
                return name, groupRank
            end
        end
    else
        local groupRank = groups[group]
        if groupRank then
            return group, groupRank
        end
    end
end

-- When player data is updated
RegisterNetEvent('QBCore:Player:SetPlayerData', function(playerData)
    if not source or source == '' then
        return
    end
    if playerData.metadata["isdead"] or playerData.metadata["inlaststand"] or playerData.metadata["ishandcuffed"] then
        Core.Classes.Inventory.Close()
    end
end)

-- When player is logging out
RegisterNetEvent('QBCore:Client:OnPlayerUnload', function(src)
    lib.callback.await(Config.ServerEventPrefix .. 'SavePlayerInventory', false)
end)
