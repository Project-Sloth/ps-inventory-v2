-- Makes ped use weapon
RegisterNetEvent(Config.ClientEventPrefix .. 'UseWeapon', function(weaponData, shootBool)
    Framework.Client.UseWeapon(source, weaponData, shootBool)
end)

-- Checks weapon
RegisterNetEvent(Config.ClientEventPrefix .. 'CheckWeapon', function(weaponName)
    Framework.Client.CheckWeapon(source, weaponName)
end)