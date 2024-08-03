-------------------------------------------------
--- GETS CORE OBJECT
-------------------------------------------------
Framework.GetCoreObject = function ()
	Framework.CoreName = "qb"
	Framework.Core = exports['qb-core']:GetCoreObject()
	Framework.Client.EventPlayerLoaded = "QBCore:Client:OnPlayerLoaded"
	
	return Framework.Core
end

-------------------------------------------------
--- GET INVENTORY ITEMS
-------------------------------------------------
Framework.Server.GetInventoryItems = function (src)
    return Framework.Core.Shared.Items
end

-------------------------------------------------
--- GET PLAYERS 
-------------------------------------------------
Framework.Server.GetPlayers = function (src)
    return Framework.Core.Functions.GetPlayers()
end

-------------------------------------------------
--- GET PLAYER 
-------------------------------------------------
Framework.Server.GetPlayer = function (src)
    return Framework.Core.Functions.GetPlayer(src)
end

-------------------------------------------------
--- GET PLAYER CASH 
-------------------------------------------------
Framework.Server.GetPlayerCash = function (src)
    local Player = Framework.Server.GetPlayer(src)
	if not Player then return nil end
	return Player.PlayerData.money.cash
end

-------------------------------------------------
--- CHARGE PLAYER
-------------------------------------------------
Framework.Server.ChargePlayer = function (src, fundSource, amount, reason)
	local Player = Framework.Server.GetPlayer(src)
	if not Player then return nil end
	Player.Functions.RemoveMoney(fundSource, amount, reason and reason or "No description available")
	return true
end

-------------------------------------------------
--- GET PLAYER IDENTITY
-------------------------------------------------
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

-------------------------------------------------
--- GET PLAYER 
-------------------------------------------------
Framework.Server.GetPlayerInventory = function (src)
    local Player = Framework.Server.GetPlayer(src)
	if not Player then return end
	return Player.PlayerData.items
end

-------------------------------------------------
--- SAVES PLAYER INVENTORY 
-------------------------------------------------
Framework.Server.SavePlayerInventory = function (src, inventory, database)
	local Player = Framework.Server.GetPlayer(src)
	if not Player then return false end

	if type(inventory) == "table" then
		Player.Functions.SetPlayerData("items", inventory)
	else
		inventory = Framework.Server.GetPlayerInventory(src)
	end

	-- Only update the database under the following conditionals
	if (Config.Player.DatabaseSyncingThread == true and database == true) or (not Config.Player.DatabaseSyncingThread and database == false)  then
		MySQL.prepare('UPDATE players SET inventory = ? WHERE citizenid = ?', { 
			(table.type(inventory) == "empty" and "[]" or json.encode(inventory)), 
			Player.PlayerData.citizenid 
		})

		Utilities.Log({
			type = "success",
			title = "PlayerInventory",
			message = "Saved inventory for " .. Player.PlayerData.citizenid
		})
	end

	return true
end

-------------------------------------------------
--- UPDATE PLAYER PLAYER 
-------------------------------------------------
Framework.Server.UpdatePlayer = function (src, key, val)
	local Player = Framework.Server.GetPlayer(src)
	if not Player then return end
    return Player.Functions.SetPlayerData(key, val)
end

-------------------------------------------------
--- GET PLAYER NAME
-------------------------------------------------
Framework.Server.GetPlayerName = function (src)
    -- Attempt to get Player table
    local Player = Framework.Core.Functions.GetPlayer(src)
        
    -- If unavailable, return server player name
    if Player == nil then return GetPlayerName(src) end

    -- Return player name
    return Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
end

-------------------------------------------------
--- GET PLAYER IDENTIFIER
-------------------------------------------------
Framework.Server.GetPlayerIdentifier = function (src)
    local Player = Framework.Core.Functions.GetPlayer(src)
    return Player.PlayerData.citizenid
end

-------------------------------------------------
--- CREATE USEABLE ITEM 
-------------------------------------------------
Framework.Server.CreateUseableItem = function (itemName, data)
    return Framework.Core.Functions.CreateUseableItem(itemName, data)
end

-------------------------------------------------
--- GET USEABLE ITEM 
-------------------------------------------------
Framework.Server.GetUseableItem = function (itemName)
    return Framework.Core.Functions.CanUseItem(itemName)
end

-------------------------------------------------
--- LOADS EXTERNAL INVENTORY
-------------------------------------------------
Framework.Server.LoadExternalInventory = function (inventoryId)
	local query = 'SELECT * FROM inventories WHERE identifier = ?'
	local res = MySQL.single.await(query, { inventoryId })
	return res
end

-------------------------------------------------
--- SAVES EXTERNAL INVENTORY
-------------------------------------------------
Framework.Server.SaveExternalInventory = function (type, inventoryId, items)
	return MySQL.insert.await('INSERT INTO inventories (identifier, items) VALUES (:identifier, :items) ON DUPLICATE KEY UPDATE items = :items', {
		['identifier'] = type .. '--' .. inventoryId,
		['items'] = json.encode(items)
	})
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
--- Override QB Functions
-------------------------------------------------
Framework.Server.SetupPlayer = function (Player, initial)

	Player.PlayerData.inventory = Player.PlayerData.items
	Player.PlayerData.identifier = Player.PlayerData.citizenid
	Player.PlayerData.name = ('%s %s'):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname)

	Framework.Core.Functions.AddPlayerMethod(Player.PlayerData.source, "AddItem", function(item, amount, slot, info)
		return Classes.Inventory.AddItem(Player.PlayerData.source, item, amount, slot, info)
	end)

	Framework.Core.Functions.AddPlayerMethod(Player.PlayerData.source, "RemoveItem", function(item, amount, slot)
		return Classes.Inventory.RemoveItem(Player.PlayerData.source, item, amount, slot)
	end)

	Framework.Core.Functions.AddPlayerMethod(Player.PlayerData.source, "GetItemBySlot", function(slot)
		return Classes.Inventory.GetSlot(Player.PlayerData.source, slot)
    end)

	Framework.Core.Functions.AddPlayerMethod(Player.PlayerData.source, "GetItemByName", function(itemName)
		return Classes.Inventory.GetSlotWithItem(Player.PlayerData.source, itemName)
	end)

	Framework.Core.Functions.AddPlayerMethod(Player.PlayerData.source, "GetItemsByName", function(itemName)
		return Classes.Inventory.GetSlotsWithItem(Player.PlayerData.source, itemName)
	end)

	Framework.Core.Functions.AddPlayerMethod(Player.PlayerData.source, "ClearInventory", function(filterItems)
		return Classes.Inventory.ClearInventory(Player.PlayerData.source, filterItems)
	end)

	Framework.Core.Functions.AddPlayerMethod(Player.PlayerData.source, "SetInventory", function(items)
		return Framework.Server.UpdatePlayer(Player.PlayerData.source, items)
	end)
end

-------------------------------------------------
--- Load inventory items on playerload then setup
-------------------------------------------------
AddEventHandler('QBCore:Server:PlayerLoaded', function (Player)
	local citizenid = Player.PlayerData.citizenid
	local inventory = MySQL.prepare.await('SELECT inventory FROM players WHERE citizenid = ?', { citizenid })
	Player.Functions.SetPlayerData('items', json.decode(inventory))
	Framework.Server.SetupPlayer(Player, true)
end)

-------------------------------------------------
--- Money update event
-------------------------------------------------
AddEventHandler('QBCore:Server:OnMoneyChange', function (src, type, amount)
    TriggerClientEvent(Config.ClientEventPrefix .. 'MoneyChange', src, type, amount)
end)

-------------------------------------------------
--- Make sure functions are correct for players
-------------------------------------------------
SetTimeout(500, function()

	-- Stop the following resources if they are started
	local resourcesToStop = { 'qb-shops' }
	for _, resource in pairs(resourcesToStop) do
		local resourceState = GetResourceState(resource)
		if resourceState ~= 'missing' and (resourceState == 'started' or resourceState == 'starting') then
			StopResource(resource)
		end
	end

	for _, Player in pairs(Framework.Core.Functions.GetQBPlayers()) do Framework.Server.SetupPlayer(Player) end
end)

-------------------------------------------------
--- Event overrides
-------------------------------------------------
local resourcesToOverride = { 'qb-inventory', 'ps-inventory' }
local exportsToOverride   = {
	{
		name = 'HasItem',
		func = Framework.Server.HasItem
	},
	{
		name = 'RemoveItem',
		func = Framework.Server.RemoveItem
	},
	{
		name = 'AddItem',
		func = Framework.Server.AddItem
	},
	{
		name = 'OpenInventoryById',
		func = Framework.Server.OpenInventoryById
	},
	{
		name = 'OpenInventory',
		func = function (src, stashName)
			Classes.Inventory.LoadExternalInventoryAndOpen(src, false, stashName)
		end
	}
}

for _, resource in pairs(resourcesToOverride) do
	for _, export in pairs(exportsToOverride) do
		Utilities.ExportHandler(resource, export.name, export.func)
	end
end