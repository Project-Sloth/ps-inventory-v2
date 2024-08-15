-------------------------------------------------
--- GETS CORE OBJECT
-------------------------------------------------
Framework.GetCoreObject = function ()
	return {}
end

-------------------------------------------------
--- GET INVENTORY ITEMS
-------------------------------------------------
Framework.Server.GetInventoryItems = function (src)
    return {}
end

-------------------------------------------------
--- GET PLAYERS 
-------------------------------------------------
Framework.Server.GetPlayers = function (src)
    return {}
end

-------------------------------------------------
--- GET PLAYER 
-------------------------------------------------
Framework.Server.GetPlayer = function (src)
    return {}
end

-------------------------------------------------
--- GET PLAYER CASH 
-------------------------------------------------
Framework.Server.GetPlayerCash = function (src)
    return 0
end

-------------------------------------------------
--- CHARGE PLAYER
-------------------------------------------------
Framework.Server.ChargePlayer = function (src, fundSource, amount, reason)
	return true
end

-------------------------------------------------
--- GET PLAYER IDENTITY
-------------------------------------------------
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

-------------------------------------------------
--- GET PLAYER 
-------------------------------------------------
Framework.Server.GetPlayerInventory = function (src)
    return {}
end

-------------------------------------------------
--- SAVES PLAYER INVENTORY 
-------------------------------------------------
Framework.Server.SavePlayerInventory = function (src, inventory, database)
	return true
end

-------------------------------------------------
--- UPDATE PLAYER PLAYER 
-------------------------------------------------
Framework.Server.UpdatePlayer = function (src, key, val)
	-- @todo
end

-------------------------------------------------
--- GET PLAYER NAME
-------------------------------------------------
Framework.Server.GetPlayerName = function (src)
    return GetPlayerName(src)
end

-------------------------------------------------
--- GET PLAYER IDENTIFIER
-------------------------------------------------
Framework.Server.GetPlayerIdentifier = function (src)
    return source
end

-------------------------------------------------
--- CREATE USEABLE ITEM 
-------------------------------------------------
Framework.Server.CreateUseableItem = function (itemName, data)
    return function (itemName, data)

    end
end

-------------------------------------------------
--- GET USEABLE ITEM 
-------------------------------------------------
Framework.Server.GetUseableItem = function (itemName)
    return false
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
    return false
end

-------------------------------------------------
--- Has Group
-------------------------------------------------
Framework.Server.HasGroup = function(src, group)
	return {}
end

-------------------------------------------------
--- Override QB Functions
-------------------------------------------------
Framework.Server.SetupPlayer = function (Player, initial)
	-- Do player setup here
end
