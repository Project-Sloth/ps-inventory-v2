-------------------------------------------------
--- FRAMEWORK FUNCTION OVERRIDES
--- These files are loaded based on the value set
--- for Config.Framework
-------------------------------------------------

-------------------------------------------------
--- GETS CORE OBJECT
-------------------------------------------------
Framework.GetCoreObject = function ()
	Framework.CoreName = "esx"
	Framework.Core = exports['es_extended']:getSharedObject()
	Framework.Client.EventPlayerLoaded = "esx:playerLoaded"
	return Framework.Core
end

-------------------------------------------------
--- GET PLAYER NAME
-------------------------------------------------
Framework.Client.GetPlayerName = function ()
    -- Attempt to get Player table
    local Player = Framework.Core.GetPlayerData()
        
    -- If unavailable, return server player name
    if Player == nil then return GetPlayerName(source) end

    -- Return player name
    return Player.name
end

-------------------------------------------------
--- GET PLAYER IDENTIFIER
-------------------------------------------------
Framework.Client.GetPlayerIdentifier = function ()
    local Player = Framework.Core.GetPlayerData()
    return Player.identifier
end

-------------------------------------------------
--- GET PLAYER CASH
-------------------------------------------------
Framework.Client.GetPlayerCash = function ()
    local Player = Framework.Core.GetPlayerData()
    return Player.money
end

-------------------------------------------------
--- CHECK WEAPON
-------------------------------------------------
Framework.Client.CheckWeapon = function (src, weaponName)
    
end

-------------------------------------------------
--- CHECK WEAPON
-------------------------------------------------
Framework.Client.CanOpenInventory = function ()
    return true
end

-------------------------------------------------
--- USE WEAPON
-------------------------------------------------
Framework.Client.UseWeapon = function (src, weaponData, shootBool)
    
end

-------------------------------------------------
--- Has Group
-------------------------------------------------
Framework.Client.HasGroup = function(group)
    local PlayerData = Framework.Core.GetPlayerData()
    if not PlayerData.job then return false end

    local groups = {
		[PlayerData.job.name] = PlayerData.job.grade
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

-------------------------------------------------
--- Progress bar
-------------------------------------------------
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
    return onFinish()
end

-------------------------------------------------
--- When player data is updated
-------------------------------------------------
RegisterNetEvent('esx:setPlayerData', function(PlayerData)
	
end)

-------------------------------------------------
--- When player is logging out
-------------------------------------------------
RegisterNetEvent('esx:onPlayerLogout', function (src)
    
end)