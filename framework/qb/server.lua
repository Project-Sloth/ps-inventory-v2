-------------------------------------------------
-- FRAMEWORK FUNCTION OVERRIDES
-- These files are loaded based on the value set
-- for Config.Framework
-------------------------------------------------

-- Gets core object
---@return table
Framework.GetCoreObject = function ()
	Framework.CoreName = "qb"
	Framework.Core = exports['qb-core']:GetCoreObject()
	Framework.Client.EventPlayerLoaded = "QBCore:Client:OnPlayerLoaded"
	
	return Framework.Core
end

-- Gets inventory items
---@param src number
---@return table
Framework.Server.GetInventoryItems = function (src)
    return Framework.Core.Shared.Items
end

-- Gets player list
---@param src number
---@return table
Framework.Server.GetPlayers = function (src)
    return Framework.Core.Functions.GetPlayers()
end

-- Gets player 
---@param src number
---@return table
Framework.Server.GetPlayer = function (src)
    return Framework.Core.Functions.GetPlayer(src)
end

-- Gets player cash
---@param src number
---@return number
Framework.Server.GetPlayerCash = function (src)
    local Player = Framework.Server.GetPlayer(src)
	if not Player then return nil end
	return Player.PlayerData.money.cash
end

-- Charges player
---@param src number
---@param fundSource string
---@param amount number
---@param reason? string
---@return boolean
Framework.Server.ChargePlayer = function (src, fundSource, amount, reason)
	local Player = Framework.Server.GetPlayer(src)
	if not Player then return nil end
	Player.Functions.RemoveMoney(fundSource, amount, reason and reason or "No description available")
	return true
end

-- Gets player identity
---@param src number
---@return table
Framework.Server.GetPlayerIdentity = function (src)
    local Player = Framework.Server.GetPlayer(src)
	if not Player then return nil end

	-- Return compatible table
	return {
		identifier = Player.PlayerData.citizenid,
		name = ('%s %s'):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname),
		firstname = Player.PlayerData.charinfo.firstname,
		lastname = Player.PlayerData.charinfo.lastname,
		birthdate = Player.PlayerData.charinfo.birthdate,
		gender = Player.PlayerData.charinfo.gender
	}
end

-- Gets player inventory 
---@param src number
---@return table
Framework.Server.GetPlayerInventory = function (src)
    local Player = Framework.Server.GetPlayer(src)
	if not Player then return end
	return Player.PlayerData.items
end

-- Saves player inventory
---@param src number
---@param inventory table
---@param database boolean
---@return boolean
Framework.Server.SavePlayerInventory = function (src, inventory, database)
	local Player = Framework.Server.GetPlayer(src)
	if not Player then return false end

	if type(inventory) == "table" then
		Player.Functions.SetPlayerData("items", inventory)
	else
		inventory = Framework.Server.GetPlayerInventory(src)
	end

	if type(inventory) ~= "table" then
		return false
	end

	-- Only update the database under the following conditionals
	if (Config.Player.DatabaseSyncingThread == true and database == true) or (not Config.Player.DatabaseSyncingThread and database == false)  then
		MySQL.prepare('UPDATE players SET inventory = ? WHERE citizenid = ?', { 
			(table.type(inventory) == "empty" and "[]" or json.encode(inventory)), 
			Player.PlayerData.citizenid 
		})

		Core.Utilities.Log({
			type = "success",
			title = "PlayerInventory",
			message = "Saved inventory for " .. Player.PlayerData.citizenid
		})
	end

	return true
end

-- Updates player 
---@param src number
---@param key any
---@param val any
---@return boolean
Framework.Server.UpdatePlayer = function (src, key, val)
	local Player = Framework.Server.GetPlayer(src)
	if not Player then return end
    return Player.Functions.SetPlayerData(key, val)
end

-- Gets player name
---@param src number
---@return string
Framework.Server.GetPlayerName = function (src)
    -- Attempt to get Player table
    local Player = Framework.Core.Functions.GetPlayer(src)
        
    -- If unavailable, return server player name
    if Player == nil then return GetPlayerName(src) end

    -- Return player name
    return Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
end

-- Gets player identifier
---@param src number
---@return string|number
Framework.Server.GetPlayerIdentifier = function (src)
    local Player = Framework.Core.Functions.GetPlayer(src)
    return Player.PlayerData.citizenid
end

-- Creates useable item
---@param itemName string
---@param data table
---@return function
Framework.Server.CreateUseableItem = function (itemName, data)
    return Framework.Core.Functions.CreateUseableItem(itemName, data)
end

-- Gets useable item
---@param itemName string
---@return boolean
Framework.Server.GetUseableItem = function (itemName)
    return Framework.Core.Functions.CanUseItem(itemName)
end

-- Checks if player has item
---@param source number
---@param items table
---@param amount number
---@return boolean
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

-- Checks if player has a specific license
---@param src number
---@param licenseType string
---@return boolean
Framework.Server.HasLicense = function (src, licenseType)
	if not licenseType then return false end
	local Player = Framework.Core.Functions.GetPlayer(src)
	if not Player then return false end
	local licenses = Player.PlayerData.metadata["licences"]
	if type(licenses[licenseType]) == nil then return false end
	if licenses[licenseType] == true then return true end
end

-- Checks if player has group
---@param src number
---@return boolean
Framework.Server.HasGroup = function(src, group)
	local Player = Framework.Core.Functions.GetPlayer(src)

	local groups = {
        [Player.PlayerData.job.name] = Player.PlayerData.job.grade.level,
        [Player.PlayerData.gang.name] = Player.PlayerData.gang.grade.level
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

-- Increases player experience
---@param source number
---@param amount number
---@param type string
---@return boolean
Framework.Server.IncreaseExp = function (source, amount, type)
    local Player = Framework.Core.Functions.GetPlayer(source)
	if not Player then return false end
    local current = Player.Functions.GetRep(type)
	local new = current + amount
	Player.Functions.AddRep(type, new)
	return true
end

-- Get player experience by type
---@param source number
---@param type string
---@return number
Framework.Server.GetExp = function (source, type)
    local Player = Framework.Core.Functions.GetPlayer(source)
	if not Player then return false end
    if not Player.PlayerData.metadata[type] then return 0 end
	return Player.PlayerData.metadata[type]
end

Framework.Server.AddMoney = function (source, type, amount)
	local Player = Framework.Core.Functions.GetPlayer(source)
	if not Player then return false end
	return Player.Functions.AddMoney(type, amount)
end

Framework.Server.RemoveMoney = function (source, type, amount)
	local Player = Framework.Core.Functions.GetPlayer(source)
	if not Player then return false end
	return Player.Functions.RemoveMoney(type, amount)
end

-- Override QB Functions
Framework.Server.SetupPlayer = function (Player, initial)

	Player.PlayerData.identifier = Player.PlayerData.citizenid
	Player.PlayerData.name = ('%s %s'):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname)

	Core.Classes.Inventory.SetItem(Player.PlayerData.source, 'money', Player.PlayerData.money.cash)

	Framework.Core.Functions.AddPlayerMethod(Player.PlayerData.source, "AddItem", function(item, amount, slot, info)
		return Core.Classes.Inventory.AddItem(Player.PlayerData.source, item, amount, slot, info)
	end)

	Framework.Core.Functions.AddPlayerMethod(Player.PlayerData.source, "RemoveItem", function(item, amount, slot)
		return Core.Classes.Inventory.RemoveItem(Player.PlayerData.source, item, amount, slot)
	end)

	Framework.Core.Functions.AddPlayerMethod(Player.PlayerData.source, "GetItemBySlot", function(slot)
		return Core.Classes.Inventory.GetSlot(Player.PlayerData.source, slot)
    end)

	Framework.Core.Functions.AddPlayerMethod(Player.PlayerData.source, "GetItemByName", function(itemName)
		return Core.Classes.Inventory.GetSlotWithItem(Player.PlayerData.source, itemName)
	end)

	Framework.Core.Functions.AddPlayerMethod(Player.PlayerData.source, "GetItemsByName", function(itemName)
		return Core.Classes.Inventory.GetSlotsWithItem(Player.PlayerData.source, itemName)
	end)

	Framework.Core.Functions.AddPlayerMethod(Player.PlayerData.source, "ClearInventory", function(filterItems)
		return Core.Classes.Inventory.ClearInventory(Player.PlayerData.source, filterItems)
	end)

	Framework.Core.Functions.AddPlayerMethod(Player.PlayerData.source, "SetInventory", function(items)
		return Framework.Server.UpdatePlayer(Player.PlayerData.source, items)
	end)
end

-- Sets player inventory and function overrides
---@param Player number
function PlayerLoadedEvent (Player)
	local citizenid = Player.PlayerData.citizenid
	local inventory = {}
	local inventoryRes = MySQL.single.await('SELECT inventory FROM players WHERE citizenid = ?', { citizenid })
	if inventoryRes then inventory = json.decode(inventoryRes.inventory) end
	Player.Functions.SetPlayerData('items', inventory)
	Framework.Server.SetupPlayer(Player, true)
end

-- Reset overrides on restart
AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
		for _, Player in pairs(Framework.Core.Functions.GetQBPlayers()) do PlayerLoadedEvent(Player) end
    end
end)

-- Load inventory items on playerload then setup
AddEventHandler('QBCore:Server:PlayerLoaded', function (Player)
	PlayerLoadedEvent(Player)
end)

-- Money update event
AddEventHandler('QBCore:Server:OnMoneyChange', function (src, type, amount)

	-- Update inventory
	if type == "cash" then
		Core.Classes.Inventory.SetItem(src, 'money', Framework.Server.GetPlayerCash(src))
	end

    TriggerClientEvent(Config.ClientEventPrefix .. 'MoneyChange', src, type, amount)
end)

-- Make sure functions are correct for players
SetTimeout(500, function()

	-- Stop the following resources if they are started
	local resourcesToStop = { 'qb-shops', 'qb-inventory' }
	for _, resource in pairs(resourcesToStop) do
		local resourceState = GetResourceState(resource)
		if resourceState ~= 'missing' and (resourceState == 'started' or resourceState == 'starting') then
			StopResource(resource)
		end
	end

	for _, Player in pairs(Framework.Core.Functions.GetQBPlayers()) do PlayerLoadedEvent(Player) end
end)

-- Event overrides
Core.Utilities.ExportHandler('qb-inventory', 'HasItem', Framework.Server.HasItem)
Core.Utilities.ExportHandler('qb-inventory', 'RemoveItem', Core.Classes.Inventory.RemoveItem)
Core.Utilities.ExportHandler('qb-inventory', 'AddItem', Core.Classes.Inventory.AddItem)
Core.Utilities.ExportHandler('qb-inventory', 'OpenInventory', function (src, stashName)
	Core.Classes.Inventory.LoadExternalInventoryAndOpen(src, false, stashName)
end)
