RegisterNetEvent(Config.ClientEventPrefix .. 'CheckWeapon', function(weaponName)
    if source == '' then return end

    return Core.Classes.Weapon.Check(weaponName)
end)

RegisterNetEvent(Config.ClientEventPrefix .. 'UseWeapon', function(weaponData, canFire)
    if source == '' then return end

    return Core.Classes.Weapon.Use(weaponData, canFire)
end)

RegisterNetEvent(Config.ClientEventPrefix .. 'DisarmWeapon', function()
    if source == '' then return end
    
    return Core.Classes.Weapon.Disarm()
end)

RegisterNetEvent(Config.ClientEventPrefix .. 'UseAmmoBox', function(itemRemove, itemGain)
    if source == '' then return end
        
    return Core.Classes.Weapon.AmmoBoxes(itemRemove, itemGain)
end)

-- Recoil handler
AddEventHandler('CEventGunShot', function(entities, eventEntity, args)
    local ped = PlayerPedId()
    if eventEntity ~= ped then return end

    if IsPedDoingDriveby(ped) then return end

    local _, weapon = GetCurrentPedWeapon(ped, false)
    local weaponName = Core.Classes.Weapon.GetByHash(weapon)
    if not weaponName then return end

    local recoil = Config.Weapons.Recoil[weaponName]
    if not recoil then return end
    if recoil == 0 then return end

    local tv = 0
    if GetFollowPedCamViewMode() ~= 4 then
        repeat
            Wait(0)
            local p = GetGameplayCamRelativePitch()
            SetGameplayCamRelativePitch(p + 0.1, 0.2)
            tv = tv + 0.1
        until tv >= recoil
    else
        repeat
            Wait(0)

            local p = GetGameplayCamRelativePitch()
            if recoil > 0.1 then
                SetGameplayCamRelativePitch(p + 0.6, 1.2)
                tv = tv + 0.6
            else
                SetGameplayCamRelativePitch(p + 0.016, 0.333)
                tv = tv + 0.1
            end
        until tv >= recoil
    end
end)
