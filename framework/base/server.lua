
-- Gets core object
---@return table
Framework.GetCoreObject = function ()
	return {}
end

-- Gets inventory items
---@param src number
---@return table
Framework.Server.GetInventoryItems = function (src)
    return {}
end

-- Gets player list
---@param src number
---@return table
Framework.Server.GetPlayers = function (src)
    return {}
end

-- Gets player 
---@param src number
---@return table
Framework.Server.GetPlayer = function (src)
    return {}
end

-- Gets player cash
---@param src number
---@return number
Framework.Server.GetPlayerCash = function (src)
    return 0
end

-- Charges player
---@param src number
---@param fundSource string
---@param amount number
---@param reason? string
---@return boolean
Framework.Server.ChargePlayer = function (src, fundSource, amount, reason)
	return true
end

-- Gets player identity
---@param src number
---@return table
Framework.Server.GetPlayerIdentity = function (src)

	-- Example return
	return {
		identifier = src,
		name = GetPlayerName(src),
		firstname = GetPlayerName(src),
		lastname = '',
		birthdate = 'N/A',
		gender = 'N/A'
	}
end

-- Gets player inventory 
---@param src number
---@return table
Framework.Server.GetPlayerInventory = function (src)
    return {}
end

-- Saves player inventory
---@param src number
---@param inventory table
---@param database boolean
---@return boolean
Framework.Server.SavePlayerInventory = function (src, inventory, database)
	return true
end

-- Updates player 
---@param src number
---@param key any
---@param val any
---@return boolean
Framework.Server.UpdatePlayer = function (src, key, val)
	return true
end

-- Gets player name
---@param src number
---@return string
Framework.Server.GetPlayerName = function (src)
    return GetPlayerName(src)
end

-- Gets player identifier
---@param src number
---@return string|number
Framework.Server.GetPlayerIdentifier = function (src)
    return source
end

-- Creates useable item
---@param itemName string
---@param data table
---@return function
Framework.Server.CreateUseableItem = function (itemName, data)
    return function (itemName, data)

    end
end

-- Gets useable item
---@param itemName string
---@return boolean
Framework.Server.GetUseableItem = function (itemName)
    return false
end

-- Loads external inventory
---@param inventoryId string
---@return table
Framework.Server.LoadExternalInventory = function (inventoryId)
	local query = 'SELECT * FROM inventories WHERE identifier = ?'
	local res = MySQL.single.await(query, { inventoryId })
	return res
end

-- Saves external inventory
---@param type string
---@param inventoryId string
---@param items table
---@return table
Framework.Server.SaveExternalInventory = function (type, inventoryId, items)
	return MySQL.insert.await('INSERT INTO inventories (identifier, items) VALUES (:identifier, :items) ON DUPLICATE KEY UPDATE items = :items', {
		['identifier'] = type .. '--' .. inventoryId,
		['items'] = json.encode(items)
	})
end

-- Checks if player has item
---@param source number
---@param items table
---@param amount number
---@return boolean
Framework.Server.HasItem = function (source, items, amount)
    return false
end

-- Checks if player has a specific license
---@param src number
---@param licenseType string
---@return boolean
Framework.Server.HasLicense = function (src, licenseType)
	if not licenseType then return false end
	return false
end

-- Checks if player has group
---@param src number
---@return boolean
Framework.Server.HasGroup = function(src, group)
	return false
end

-- Increases player experience
---@param source number
---@param amount number
---@param type string
---@return boolean
Framework.Server.IncreaseExp = function (source, amount, type)
    return false
end

-- Get player experience by type
---@param source number
---@param type string
Framework.Server.GetExp = function (source, type)
    return 0
end

-- Setup player
---@param player number
---@param initial boolean
Framework.Server.SetupPlayer = function (player, initial)
	-- Do player setup here
end
