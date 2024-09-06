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

	-- Warn of old QBCore
	if Config.OldCore then
		Core.Utilities.Log({
			force = true,
			type = "warning",
			title = "Old QBCore Determined",
			message = "Please consider upgrading to the latest version of QBCore as this inventory is not heavily tested for backwards compatibility."
		})
	end
	
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
    local player = Framework.Server.GetPlayer(src)
	if not player then return nil end
	return player.PlayerData.money.cash
end

-- gets players money 
---@param src number
---@return number
Framework.Server.GetPlayerMoney = function (src)
    local player = Framework.Server.GetPlayer(src)
	if not player then return nil end
	return player.PlayerData.money.cash, player.PlayerData.money.bank
end


-- Charges player
---@param src number
---@param fundSource string
---@param amount number
---@param reason? string
---@return boolean
Framework.Server.ChargePlayer = function (src, fundSource, amount, reason)
	local player = Framework.Server.GetPlayer(src)
	if not player then return nil end
	if not player.Functions.RemoveMoney('cash', amount, reason and reason or "No description available") then 
		if not  player.Functions.RemoveMoney('bank', amount, reason and reason or "No description available") then return false end
	end
	return true
end


-- Gets player identity
---@param src number
---@return table
Framework.Server.GetPlayerIdentity = function (src)
    local player = Framework.Server.GetPlayer(src)
	if not player then return nil end

	-- Return compatible table
	return {
		identifier = player.PlayerData.citizenid,
		name = ('%s %s'):format(player.PlayerData.charinfo.firstname, player.PlayerData.charinfo.lastname),
		firstname = player.PlayerData.charinfo.firstname,
		lastname = player.PlayerData.charinfo.lastname,
		birthdate = player.PlayerData.charinfo.birthdate,
		gender = player.PlayerData.charinfo.gender
	}
end

-- Gets player inventory 
---@param src number
---@return table
Framework.Server.GetPlayerInventory = function (src)
    local player = Framework.Server.GetPlayer(src)
	if not player then return end
	return player.PlayerData.items
end

-- Saves player inventory
---@param src number
---@param inventory table
---@param database boolean
---@return boolean
Framework.Server.SavePlayerInventory = function (src, inventory, database)
	local player = Framework.Server.GetPlayer(src)
	if not player then return false end

	if type(inventory) == "table" then
		player.Functions.SetPlayerData("items", inventory)
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
			player.PlayerData.citizenid 
		})

		Core.Utilities.Log({
			type = "success",
			title = "PlayerInventory",
			message = "Saved inventory for " .. player.PlayerData.citizenid
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
	local player = Framework.Server.GetPlayer(src)
	if not player then return end
    return player.Functions.SetPlayerData(key, val)
end

-- Gets player name
---@param src number
---@return string
Framework.Server.GetPlayerName = function (src)
    -- Attempt to get Player table
    local player = Framework.Core.Functions.GetPlayer(src)
        
    -- If unavailable, return server player name
    if player == nil then return GetPlayerName(src) end

    -- Return player name
    return player.PlayerData.charinfo.firstname .. " " .. player.PlayerData.charinfo.lastname
end

-- Gets player identifier
---@param src number
---@return string|number
Framework.Server.GetPlayerIdentifier = function (src)
    local player = Framework.Core.Functions.GetPlayer(src)
    return player.PlayerData.citizenid
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
	local player = Framework.Core.Functions.GetPlayer(src)
	if not player then return false end
	local licenses = player.PlayerData.metadata["licences"]
	if type(licenses[licenseType]) == nil then return false end
	if licenses[licenseType] == true then return true end
end

-- Checks if player has group
---@param src number
---@return boolean
Framework.Server.HasGroup = function(src, group)
	local player = Framework.Core.Functions.GetPlayer(src)

	local groups = {
        [player.PlayerData.job.name] = player.PlayerData.job.grade.level,
        [player.PlayerData.gang.name] = player.PlayerData.gang.grade.level
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
    local player = Framework.Core.Functions.GetPlayer(source)
	if not player then return false end
    local current = player.Functions.GetRep(type)
	local new = current + amount
	player.Functions.AddRep(type, new)
	return true
end

-- Get player experience by type
---@param source number
---@param type string
---@return number
Framework.Server.GetExp = function (source, type)
    local player = Framework.Core.Functions.GetPlayer(source)
	if not player then return false end
    if not player.PlayerData.metadata['rep'][type] then return 0 end
	return player.PlayerData.metadata['rep'][type]
end

Framework.Server.AddMoney = function (source, type, amount)
	local player = Framework.Core.Functions.GetPlayer(source)
	if not player then return false end
	return player.Functions.AddMoney(type, amount)
end

Framework.Server.RemoveMoney = function (source, type, amount)
	local player = Framework.Core.Functions.GetPlayer(source)
	if not player then return false end
	return player.Functions.RemoveMoney(type, amount)
end

-- Override QB Functions
Framework.Server.SetupPlayer = function (player, initial)

	player.PlayerData.identifier = player.PlayerData.citizenid
	player.PlayerData.name = ('%s %s'):format(player.PlayerData.charinfo.firstname, player.PlayerData.charinfo.lastname)

	Core.Classes.Inventory.SetItem(player.PlayerData.source, 'money', player.PlayerData.money.cash)

	Framework.Core.Functions.AddPlayerMethod(player.PlayerData.source, "AddItem", function(item, amount, slot, info)
		return Core.Classes.Inventory.AddItem(player.PlayerData.source, item, amount, slot, info)
	end)

	Framework.Core.Functions.AddPlayerMethod(player.PlayerData.source, "RemoveItem", function(item, amount, slot)
		return Core.Classes.Inventory.RemoveItem(player.PlayerData.source, item, amount, slot)
	end)

	Framework.Core.Functions.AddPlayerMethod(player.PlayerData.source, "GetItemBySlot", function(slot)
		return Core.Classes.Inventory.GetSlot(player.PlayerData.source, slot)
    end)

	Framework.Core.Functions.AddPlayerMethod(player.PlayerData.source, "GetItemByName", function(itemName)
		return Core.Classes.Inventory.GetSlotWithItem(player.PlayerData.source, itemName)
	end)

	Framework.Core.Functions.AddPlayerMethod(player.PlayerData.source, "GetItemsByName", function(itemName)
		return Core.Classes.Inventory.GetSlotsWithItem(player.PlayerData.source, itemName)
	end)

	Framework.Core.Functions.AddPlayerMethod(player.PlayerData.source, "ClearInventory", function(filterItems)
		return Core.Classes.Inventory.ClearInventory(player.PlayerData.source, filterItems)
	end)

	Framework.Core.Functions.AddPlayerMethod(player.PlayerData.source, "SetInventory", function(items)
		return Framework.Server.UpdatePlayer(player.PlayerData.source, items)
	end)
end

-- Sets player inventory and function overrides
---@param player number
function PlayerLoadedEvent (player)
	local citizenid = player.PlayerData.citizenid
	local inventory = {}
	local inventoryRes = MySQL.single.await('SELECT inventory FROM players WHERE citizenid = ?', { citizenid })
	if inventoryRes then inventory = json.decode(inventoryRes.inventory) end
	player.Functions.SetPlayerData('items', inventory)
	Framework.Server.SetupPlayer(player, true)
end

-- Reset overrides on restart
AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
		for _, player in pairs(Framework.Core.Functions.GetQBPlayers()) do PlayerLoadedEvent(player) end
    end
end)

-- Load inventory items on playerload then setup
AddEventHandler('QBCore:Server:PlayerLoaded', function (player)
	PlayerLoadedEvent(player)
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
	local resourcesToStop = { 'qb-shops', 'qb-inventory', 'qb-weapons' }
	for _, resource in pairs(resourcesToStop) do
		local resourceState = GetResourceState(resource)
		if resourceState ~= 'missing' and (resourceState == 'started' or resourceState == 'starting') then
			StopResource(resource)
		end
	end

	for _, player in pairs(Framework.Core.Functions.GetQBPlayers()) do PlayerLoadedEvent(player) end
end)

-- Event overrides
Core.Utilities.ExportHandler('qb-inventory', 'HasItem', Framework.Server.HasItem)
Core.Utilities.ExportHandler('qb-inventory', 'RemoveItem', Core.Classes.Inventory.RemoveItem)
Core.Utilities.ExportHandler('qb-inventory', 'AddItem', Core.Classes.Inventory.AddItem)
Core.Utilities.ExportHandler('qb-inventory', 'OpenInventoryById', Core.Classes.Inventory.OpenInventoryById)
Core.Utilities.ExportHandler('qb-inventory', 'OpenInventory', function (src, stashName)
	Core.Classes.Inventory.LoadExternalInventoryAndOpen(src, false, stashName)
end)

-------------------------------------------------
-- Server event: backwards compatibility
-------------------------------------------------
RegisterNetEvent("inventory:server:OpenInventory", function(type, id, name, table)
    local src = source
    if type == 'stash' then
        Core.Classes.Inventory.OpenStash(source, id)
    elseif type == 'shop'then
        Core.Classes.Shops.Open(source, id, name)
    end
end)

-------------------------------------------------
-- Server event for opening inventory
-------------------------------------------------
RegisterNetEvent("qb-inventory:server:OpenInventory", function(type, id, name, table)
    local src = source
    if type == 'stash' then
        Core.Classes.Inventory.OpenStash(source, id)
    elseif type == 'shop'then
        Core.Classes.Shops.Open(source, id, name)
    end
end)

-------------------------------------------------
-- Conversion of old qb core inventories
-------------------------------------------------
if Config.OldCore and Config.ConvertInventories then
    CreateThread(function()

		Core.Utilities.Log({
			force = true,
			type = "warning",
			title = "QB.ConvertInventory",
			message = "Processing conversion of stashes, trunks, and gloveboxes."
		})

		-- Process old stashes
		local stashTableCheck = MySQL.single.await('SHOW TABLES LIKE ?', { 'stashitems' })
		if not stashTableCheck then
			Core.Utilities.Log({
				force = true,
				type = 'error',
				title = "QB.ConvertInventory.Stashes",
				message = "Table `stashitems` does not exist. Skipping conversion for stashes."
			})
		end

		if stashTableCheck then
			local stash = MySQL.query.await('SELECT * FROM stashitems')
			if not stash[1] then return end
			for i = 1, #stash do 
				MySQL.insert('INSERT INTO inventories SET identifier = ?, items = ?', {'stash--' .. stash[i].stash, stash[i].items})

				Core.Utilities.Log({
					force = true,
					type = "success",
					title = "QB.ConvertInventory.Stashes",
					message = ("Processing Stash: %s"):format(stash[i].stash)
				})

				if Config.RemoveOldCoreInventories then
					MySQL.query.await('DELETE FROM stashitems WHERE stash = ? AND items = ?', {stash[i].stash, stash[i].items})
				end
			end
		end

		-- Process old trunk storage
		local trunkTableCheck = MySQL.single.await('SHOW TABLES LIKE ?', { 'trunkitems' })
		if not trunkTableCheck then
			Core.Utilities.Log({
				force = true,
				type = 'error',
				title = "QB.ConvertInventory.Trunks",
				message = "Table `trunkitems` does not exist. Skipping conversion for trunks."
			})
		end

		if trunkTableCheck then
        	local trunk = MySQL.query.await('SELECT * FROM trunkitems')
        	if not trunk[1] then return end
			for i = 1, #trunk do 
				MySQL.insert('INSERT INTO inventories SET identifier = ?, items = ?', {'stash--trunk-' .. trunk[i].plate, trunk[i].items})

				Core.Utilities.Log({
					force = true,
					type = "success",
					title = "QB.ConvertInventory.Trunks",
					message = ("Processing Trunk: %s"):format(trunk[i].plate)
				})

				if Config.RemoveOldCoreInventories then
					MySQL.query.await('DELETE FROM trunkitems WHERE plate = ? AND items = ?', {trunk[i].plate, stash[i].items})
				end
			end
		end

		-- Process old glovebox storage
		local gloveTableCheck = MySQL.single.await('SHOW TABLES LIKE ?', { 'gloveboxitems' })
		if not gloveTableCheck then
			Core.Utilities.Log({
				force = true,
				type = 'error',
				title = "QB.ConvertInventory.Gloveboxes",
				message = "Table `gloveboxitems` does not exist. Skipping conversion for gloveboxes."
			})
		end

		if gloveTableCheck then
			local glove = MySQL.query.await('SELECT * FROM gloveboxitems')
			if not glove[1] then return end
			for i = 1, #glove do 
				MySQL.insert('INSERT INTO inventories SET identifier = ?, items = ?', {'stash--glovebox-' .. glove[i].plate, glove[i].items})

				Core.Utilities.Log({
					force = true,
					type = "success",
					title = "QB.ConvertInventory.Gloveboxes",
					message = ("Processing Glovebox: %s"):format(glove[i].plate)
				})

				if Config.RemoveOldCoreInventories then
					MySQL.query.await('DELETE FROM gloveboxitems WHERE plate = ? AND items = ?', {glove[i].plate, glove[i].items})
				end
			end   
		end  
    end)
end
