-- Updates weapon ammo
lib.callback.register(Config.ServerEventPrefix .. 'UpdateWeaponAmmo', function(source, weaponData, amount)
    return Core.Classes.Weapon.UpdateAmmo(source, weaponData, amount)
end)

-- Remove weapon attachment
lib.callback.register(Config.ServerEventPrefix .. 'RemoveWeaponAttachment', function(source, attachmentData, weaponState)
    return Core.Classes.Weapon.RemoveAttachment(source, attachmentData, weaponState)
end)