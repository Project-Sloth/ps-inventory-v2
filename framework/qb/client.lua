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
    local player = Framework.Core.Functions.GetPlayerData()
        
    -- If unavailable, return server player name
    if player == nil then return GetPlayerName(source) end

    -- Return player name
    return player.charinfo.firstname .. " " .. player.charinfo.lastname
end

-- Get player identifier
---@return string
Framework.Client.GetPlayerIdentifier = function ()
    local player = Framework.Core.Functions.GetPlayerData()
    return player.citizenid
end

-- Get player cash
---@return number
Framework.Client.GetPlayerCash = function ()
    local player = Framework.Core.Functions.GetPlayerData()
    return player.money.cash
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
    local playerData = Framework.Core.Functions.GetPlayerData()
    if not playerData then return false end

    if playerData.metadata["isdead"] or playerData.metadata["inlaststand"] or playerData.metadata["ishandcuffed"] or IsPauseMenuActive() then
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
    local playerData = Framework.Core.Functions.GetPlayerData()
    if not playerData.job then return false end

    local groups = {
        [playerData.job.name] = playerData.job.grade.level,
        [playerData.gang.name] = playerData.gang.grade.level,
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
Framework.Client.Progressbar = function (text, time, anim, data)
    TriggerEvent('animations:client:EmoteCommandStart', {anim}) 
	if Config.Progressbar == 'oxbar' then 
	  if lib.progressBar({ duration = time, label = text, useWhileDead = data.useWhileDead or false, canCancel = data.canCancel or true,
            disable = { car = data.disable.car or true, move = data.disable.move or true, combat = data.disable.combat or true, sprint = data.disable.sprint or true,},}) then 
		if GetResourceState('scully_emotemenu') == 'started' then
			exports.scully_emotemenu:cancelEmote()
		else
			TriggerEvent('animations:client:EmoteCommandStart', {"c"}) 
		end
		return true
	  end	 
	elseif Config.Progressbar == 'oxcircle' then
	  if lib.progressCircle({ position = 'bottom', duration = time, label = text, useWhileDead = data.useWhileDead or false, canCancel = data.canCancel or true,
            disable = { car = data.disable.car or true, move = data.disable.move or true, combat = data.disable.combat or true, sprint = data.disable.sprint or true,},}) then 
		if GetResourceState('scully_emotemenu') == 'started' then
			exports.scully_emotemenu:cancelEmote()
		else
			TriggerEvent('animations:client:EmoteCommandStart', {"c"}) 
		end
		return true
	  end
	elseif Config.Progressbar == 'qb' then
	local test = false
		local cancelled = false
        Framework.Core.Functions.Progressbar("drink_something", text, time, false, true, { 
        disableMovement = data.disable.move or true, 
        disableCarMovement = data.disable.car or true,
        disableMouse = data.disable.mouse or true, 
        disableCombat = data.disable.combat or true, 
        disableInventory = true,
	  }, {}, {}, {}, function()-- Done
		test = true
		if GetResourceState('scully_emotemenu') == 'started' then
			exports.scully_emotemenu:cancelEmote()
		else
			TriggerEvent('animations:client:EmoteCommandStart', {"c"}) 
		end
	  end, function()
		cancelled = true
		if GetResourceState('scully_emotemenu') == 'started' then
			exports.scully_emotemenu:cancelEmote()
		else
			TriggerEvent('animations:client:EmoteCommandStart', {"c"}) 
		end
	end)
	  repeat 
		Wait(100)
	  until cancelled or test
	  if test then return true end
	else
		print"dude, it literally tells you what you need to set it as in the config"
	end	  
end

-- When player data is updated
RegisterNetEvent('QBCore:Player:SetPlayerData', function(playerData)
	if not source or source == '' then return end
	if playerData.metadata["isdead"] or playerData.metadata["inlaststand"] or playerData.metadata["ishandcuffed"] then
		Core.Classes.Inventory.Close()
	end
end)

-- When player is logging out
RegisterNetEvent('QBCore:Client:OnPlayerUnload', function (src)
    lib.callback.await(Config.ServerEventPrefix .. 'SavePlayerInventory', false)
end)
