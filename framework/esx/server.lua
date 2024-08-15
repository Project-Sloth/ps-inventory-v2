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
--- GET INVENTORY ITEMS
-------------------------------------------------
Framework.Server.GetInventoryItems = function (src)
    
end

-------------------------------------------------
--- GET PLAYERS 
-------------------------------------------------
Framework.Server.GetPlayers = function (src)
    local xPlayers = Framework.Core.GetPlayers()
	return xPlayers
end

-------------------------------------------------
--- GET PLAYER 
-------------------------------------------------
Framework.Server.GetPlayer = function (src)
    local xPlayer = Framework.Core.GetPlayerFromId(src)
	return xPlayer
end

-------------------------------------------------
--- GET PLAYER CASH 
-------------------------------------------------
Framework.Server.GetPlayerCash = function (src)
    
end

-------------------------------------------------
--- CHARGE PLAYER
-------------------------------------------------
Framework.Server.ChargePlayer = function (src, fundSource, amount, reason)
	
end

-------------------------------------------------
--- GET PLAYER IDENTITY
-------------------------------------------------
Framework.Server.GetPlayerIdentity = function (src)
    
end

-------------------------------------------------
--- GET PLAYER 
-------------------------------------------------
Framework.Server.GetPlayerInventory = function (src)
    local xPlayer = Framework.Server.GetPlayer(src)
	if xPlayer == nil then return false end
	return xPlayer.getInventory()
end

-------------------------------------------------
--- SAVES PLAYER INVENTORY 
-------------------------------------------------
Framework.Server.SavePlayerInventory = function (src, inventory, database)
	
end

-------------------------------------------------
--- UPDATE PLAYER PLAYER 
-------------------------------------------------
Framework.Server.UpdatePlayer = function (src, key, val)
	
end

-------------------------------------------------
--- GET PLAYER NAME
-------------------------------------------------
Framework.Server.GetPlayerName = function (src)
    local xPlayer = Framework.Server.GetPlayer(src)
    if xPlayer == nil then return GetPlayerName(src) end
    return xPlayer.getName()
end

-------------------------------------------------
--- GET PLAYER IDENTIFIER
-------------------------------------------------
Framework.Server.GetPlayerIdentifier = function (src)
    local xPlayer = Framework.Server.GetPlayer(src)
	if xPlayer == nil then return nil end
	return xPlayer.getIdentifier()
end

-------------------------------------------------
--- CREATE USEABLE ITEM 
-------------------------------------------------
Framework.Server.CreateUseableItem = function (itemName, data)
    
end

-------------------------------------------------
--- GET USEABLE ITEM 
-------------------------------------------------
Framework.Server.GetUseableItem = function (itemName)
    
end

-------------------------------------------------
--- PLAYER HAS ITEM
-------------------------------------------------
Framework.Server.HasItem = function (source, items, amount)
    amount = amount or 1
	local count = 0

	-- Get inventory and return false if not found
	local inventory = Framework.Server.GetPlayerInventory(source)
	if not inventory then return false end

	-- If type is table, iterate over each
	if type(items) == "table" then
		for _, item in pairs(items) do
			for _, i in pairs(inventory) do
				if i.name == item and i.amount >= amount then
					count = count + 1
				end
			end
		end

		if count == #items then return true else return false end

	-- If type is string
	elseif type(items) == "string" then
		for _, i in pairs(inventory) do
			if i.name == items then
				count = count + i.amount
			end
		end

		return count >= amount

	-- If type is a mismatch
	else
		return false
	end
end

-------------------------------------------------
--- Has Group
-------------------------------------------------
Framework.Server.HasGroup = function(src, group)
	local Player = Framework.Server.GetPlayer(src)

	local groups = {
		[Player.job.name] = Player.job.grade
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
--- Override QB Functions
-------------------------------------------------
Framework.Server.SetupPlayer = function (Player, initial)

end

-------------------------------------------------
--- Sets player inventory and function overrides
-------------------------------------------------
function PlayerLoadedEvent (Player)
	
end

-------------------------------------------------
--- Reset overrides on restart
-------------------------------------------------
AddEventHandler('onResourceStart', function(resource)
    
end)

-------------------------------------------------
--- Load inventory items on playerload then setup
-------------------------------------------------
AddEventHandler('esx:playerLoaded', function (Player)
	
end)

-------------------------------------------------
--- Money update event
-------------------------------------------------
AddEventHandler('esx:setAccountMoney', function (src, type, amount)
    
end)

-------------------------------------------------
--- Make sure functions are correct for players
-------------------------------------------------
SetTimeout(500, function()

	
end)
