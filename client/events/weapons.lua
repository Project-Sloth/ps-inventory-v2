RegisterNetEvent(Config.ClientEventPrefix .. 'UseWeapon', function(weaponData, shootBool)
    Framework.Client.UseWeapon(source, weaponData, shootBool)
end)

RegisterNetEvent(Config.ClientEventPrefix .. 'CheckWeapon', function(weaponName)
    Framework.Client.CheckWeapon(source, weaponName)
end)