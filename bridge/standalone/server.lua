-------------------------------------------------
--- GETS CORE OBJECT
-------------------------------------------------
Framework.GetCoreObject = function ()
	
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
    
end

-------------------------------------------------
--- GET PLAYER 
-------------------------------------------------
Framework.Server.GetPlayer = function (src)
    
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
    
end

-------------------------------------------------
--- SAVES PLAYER INVENTORY 
-------------------------------------------------
Framework.Server.SavePlayerInventory = function (src, inventory)
	
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
    
end

-------------------------------------------------
--- GET PLAYER IDENTIFIER
-------------------------------------------------
Framework.Server.GetPlayerIdentifier = function (src)
    
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
--- LOADS EXTERNAL INVENTORY
-------------------------------------------------
Framework.Server.LoadExternalInventory = function (inventoryId)

end

-------------------------------------------------
--- SAVES EXTERNAL INVENTORY
-------------------------------------------------
Framework.Server.SaveExternalInventory = function (type, inventoryId, items)

end

-------------------------------------------------
--- PLAYER HAS ITEM
-------------------------------------------------
Framework.Server.HasItem = function (source, items, amount)

end

-------------------------------------------------
--- Player Setup
-------------------------------------------------
Framework.Server.SetupPlayer = function (Player)

end

-------------------------------------------------
--- Load inventory items on playerload then setup
-------------------------------------------------
AddEventHandler('YourCustomPlayerLoadedEvent', function (Player)
	
end)
