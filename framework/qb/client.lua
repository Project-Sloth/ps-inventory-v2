-------------------------------------------------
--- FRAMEWORK FUNCTION OVERRIDES
--- These files are loaded based on the value set
--- for Config.Framework
-------------------------------------------------

-- Get core object
Framework.GetCoreObject = function ()
	Framework.CoreName = "qb"
	Framework.Core = exports['qb-core']:GetCoreObject()
	Framework.Client.EventPlayerLoaded = "QBCore:Client:OnPlayerLoaded"
	return Framework.Core
end

-- Get player name
Framework.Client.GetPlayerName = function ()
    -- Attempt to get Player table
    local Player = Framework.Core.Functions.GetPlayerData()
        
    -- If unavailable, return server player name
    if Player == nil then return GetPlayerName(source) end

    -- Return player name
    return Player.charinfo.firstname .. " " .. Player.charinfo.lastname
end

-- Get player identifier
---@return string
Framework.Client.GetPlayerIdentifier = function ()
    local Player = Framework.Core.Functions.GetPlayerData()
    return Player.citizenid
end

-- Get player cash
---@return number
Framework.Client.GetPlayerCash = function ()
    local Player = Framework.Core.Functions.GetPlayerData()
    return Player.money.cash
end

-- Check weapon
---@param src number 
---@param weaponName string
Framework.Client.CheckWeapon = function (src, weaponName)
    TriggerEvent('qb-weapons:client:CheckWeapon', weaponName)
end

-- Can open inventory
---@return boolean
Framework.Client.CanOpenInventory = function ()
    local PlayerData = Framework.Core.Functions.GetPlayerData()
    if not PlayerData then return false end

    if PlayerData.metadata["isdead"] or PlayerData.metadata["inlaststand"] or PlayerData.metadata["ishandcuffed"] or IsPauseMenuActive() then
		return false
	end

    return true
end

-- Use weapon
---@param src number
---@param weaponData table
---@param shootBool boolean
Framework.Client.UseWeapon = function (src, weaponData, shootBool)
    TriggerEvent('qb-weapons:client:UseWeapon', weaponData, shootBool)
end

-- Has Group
---@param group table
Framework.Client.HasGroup = function(group)
    local PlayerData = Framework.Core.Functions.GetPlayerData()
    if not PlayerData.job then return false end

    local groups = {
        [PlayerData.job.name] = PlayerData.job.grade.level,
        [PlayerData.gang.name] = PlayerData.gang.grade.level,
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

-- Progress bar
Framework.Client.Progressbar = function (
    name, 
    label, 
    duration, 
    useWhileDead, 
    canCancel, 
    disableControls, 
    animation, 
    prop, 
    propTwo, 
    onFinish, 
    onCancel
)
    return Framework.Core.Functions.Progressbar(
        name, 
        label, 
        duration, 
        useWhileDead, 
        canCancel, 
        disableControls, 
        animation, 
        prop, 
        propTwo, 
        onFinish, 
        onCancel
    )
end

-- When player data is updated
RegisterNetEvent('QBCore:Player:SetPlayerData', function(PlayerData)
	if not source or source == '' then return end
	if PlayerData.metadata["isdead"] or PlayerData.metadata["inlaststand"] or PlayerData.metadata["ishandcuffed"] then
		Core.Classes.Inventory.Close()
	end
end)

-- When player is logging out
RegisterNetEvent('QBCore:Client:OnPlayerUnload', function (src)
    lib.callback.await(Config.ServerEventPrefix .. 'SavePlayerInventory', false)
end)
