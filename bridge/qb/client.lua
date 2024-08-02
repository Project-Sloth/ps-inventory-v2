Framework.Client.CurrentWeapon = false

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
--- GET PLAYER NAME
-------------------------------------------------
Framework.Client.GetPlayerName = function ()
    -- Attempt to get Player table
    local Player = Framework.Core.Functions.GetPlayerData()
        
    -- If unavailable, return server player name
    if Player == nil then return GetPlayerName(source) end

    -- Return player name
    return Player.charinfo.firstname .. " " .. Player.charinfo.lastname
end

-------------------------------------------------
--- GET PLAYER IDENTIFIER
-------------------------------------------------
Framework.Client.GetPlayerIdentifier = function ()
    local Player = Framework.Core.Functions.GetPlayerData()
    return Player.citizenid
end

-------------------------------------------------
--- GET PLAYER CASH
-------------------------------------------------
Framework.Client.GetPlayerCash = function ()
    local Player = Framework.Core.Functions.GetPlayerData()
    return Player.money.cash
end

-------------------------------------------------
--- CHECK WEAPON
-------------------------------------------------
Framework.Client.CheckWeapon = function (src, weaponName)
    TriggerEvent('qb-weapons:client:CheckWeapon', weaponName)
end

-------------------------------------------------
--- CHECK WEAPON
-------------------------------------------------
Framework.Client.CanOpenInventory = function ()
    local PlayerData = Framework.Core.Functions.GetPlayerData()
    if not PlayerData then return false end

    if PlayerData.metadata["isdead"] or PlayerData.metadata["inlaststand"] or PlayerData.metadata["ishandcuffed"] or IsPauseMenuActive() then
		return false
	end

    return true
end

-------------------------------------------------
--- USE WEAPON
-------------------------------------------------
Framework.Client.UseWeapon = function (src, weaponData, shootBool)
    TriggerEvent('qb-weapons:client:UseWeapon', weaponData, shootBool)
end

-------------------------------------------------
--- When player data is updated
-------------------------------------------------
RegisterNetEvent('QBCore:Player:SetPlayerData', function(PlayerData)
	if not source or source == '' then return end
	if PlayerData.metadata["isdead"] or PlayerData.metadata["inlaststand"] or PlayerData.metadata["ishandcuffed"] then
		Classes.Inventory.Close()
	end
end)

-------------------------------------------------
--- When player is logging out
-------------------------------------------------
RegisterNetEvent('QBCore:Client:OnPlayerUnload', function (src)
    lib.callback.await(Config.ServerEventPrefix .. 'SavePlayerInventory', false)
end)