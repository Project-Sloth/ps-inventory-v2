-------------------------------------------------
--- Weapons Setup
-------------------------------------------------

-- Unarmed weapon default
local UnarmedWeapon = "WEAPON_UNARMED"

-- Default weapon state
local defaultWeaponState = {
    canFire = true, 
    currentWeapon = false,
    currentWeaponData = nil,
    currentWeaponAmmo = 0
}

local defaultAnimation = {
    equip  = { 'reaction@intimidation@1h', 'intro', 50, 3.0, 3.0, 1400 },
    disarm = { 'reaction@intimidation@1h', 'outro', 50, 8.0, 3.0, 1400 }
}

-- Creates the weapons class
Core.Classes.New("Weapon", defaultWeaponState)

function Core.Classes.Weapon.Init ()

    -- Turn off autoreloading
    SetWeaponsNoAutoreload(true)

    -- Start the shot listener
    Core.Classes.Weapon.ShotListener()

    -- Starts the listener for damage modification
    Core.Classes.Weapon.DamageModifier()

    -- If script is restarted, find weapon player has and use
    local playerCurrentWeapon = Core.Classes.Player.CurrentWeapon()
    if playerCurrentWeapon.weapon then
        local list = Core.Classes.Weapon.List()
        for _, weaponName in pairs(list) do
            if GetHashKey(weaponName) == playerCurrentWeapon.weapon then
                local inventoryItems = Core.Classes.Inventory.FindItemsByName(weaponName)
                if Core.Utilities.TableLength(inventoryItems) then
                    return Core.Classes.Weapon.Use(inventoryItems[1])
                end
            end
        end
    end
end

-- Checks weapon state against inventory,
-- If it is no longer in inventory, disarm
function Core.Classes.Weapon.CheckAgainstInventory ()
    local weaponState = Core.Classes.Weapon.CurrentWeaponState()
    local playerCurrentWeapon = Core.Classes.Player.CurrentWeapon()

    if playerCurrentWeapon.weapon and weaponState then
        local list = Core.Classes.Weapon.List()
        for _, weaponName in pairs(list) do
            if GetHashKey(weaponName) == playerCurrentWeapon.weapon then
                local inventoryItems = Core.Classes.Inventory.FindItemsByName(weaponName)

                if Core.Utilities.TableLength(inventoryItems) == 0 then
                    return Core.Classes.Weapon.Disarm()
                end

                if inventoryItems[1].info.quality == 0 then
                    return Core.Classes.Weapon.Disarm()
                end
            end
        end
    end
end

-- Updates fire state
---@return table
function Core.Classes.Weapon.UpdateFireState (canFire)
    Core.Classes.Weapon:UpdateState('canFire', canFire)

    if not canFire then
        Core.Classes.Weapon.CheckFire()
    end
end

-- Updates current weapon and data
---@return table
function Core.Classes.Weapon.UpdateCurrentWeaponState (weapon, data)
    Core.Classes.Weapon:UpdateState({
        currentWeapon = weapon,
        currentWeaponData = data
    })
end

-- Returns current weapon
---@return table
function Core.Classes.Weapon.CurrentWeaponState ()
    local state = Core.Classes.Weapon:GetState()
    if not state.currentWeapon then
        return { weapon = nil, data = nil }
    end

    return { weapon = state.currentWeapon, data = state.currentWeaponData }
end

-- Returns list of weapons (Also includes addons )
---@return table
function Core.Classes.Weapon.List ()
    local list = Config.Weapons.List

    for _, val in pairs(Config.Weapons.AddonWeapons) do
        table.insert(list, val)
    end

    return list
end

-- Returns weapon by hash
---@param weaponHash number
function Core.Classes.Weapon.GetByHash (weaponHash)
    local list = Core.Classes.Weapon.List()

    for _, weapon in pairs(list) do
        if GetHashKey(weapon:upper()) == weaponHash then
            return weapon
        end
    end

    return false
end

-- Returns attachments list
---@return table
function Core.Classes.Weapon.Attachments ()
    return Config.Weapons.Attachments
end

-- Returns drawable weapons list
---@return table
function Core.Classes.Weapon.Animations ()
    return Config.Weapons.Animations
end

-- Checks if weapon is blaclisted
---@param weapon number
---@return boolean
function Core.Classes.Weapon.Blacklisted (weaponName)
    local blacklist = Config.Weapons.Blacklisted
    if Core.Utilities.TableHasValue(blacklist, weaponName:lower()) then return true end
    return false
end

-- Checks if weapon is in config
---@param weapon number
---@return boolean
function Core.Classes.Weapon.Exists (weapon)
    if not weapon then return false end

    if Core.Classes.Weapon.Blacklisted(weapon) then
        return false
    end

    local weaponsList = Core.Classes.Weapon.List()

    for i = 1, #weaponsList do
        if weaponsList[i] == weapon then
            return true
        end
    end

    return false
end

-- Returns if weapon has animation
-- Type = equip, disarm
---@param weaponName string
---@param type string
---@return boolean
function Core.Classes.Weapon.HasAnimation(weaponName, type)
    if not weaponName then return false end

    for weapon, animations in pairs(Core.Classes.Weapon.Animations()) do
        if weapon == weaponName then
            if animations[type] then
                return animations[type]
            end
        end
    end

    return false
end

-- Resets weapons state
---@return boolean
function Core.Classes.Weapon.ResetWeaponState ()
    return Core.Classes.Weapon:UpdateState(defaultWeaponState)
end

-- Remove weapon attachment
function Core.Classes.Weapon.RemoveAttachment (data)
    if not data.slot then return false end
    if not data.attachment then return false end
    if not data.component then return false end

    -- Make the request
    local res = lib.callback.await(
        Config.ServerEventPrefix .. 'RemoveWeaponAttachment', 
        false, 
        data, 
        Core.Classes.Weapon:GetState()
    )

    -- Check response status
    if res.success then
        Core.Classes.Inventory.Update()
    end

    return res
end

-- Checks current weapon.
---@param weaponName string
function Core.Classes.Weapon.Check (weaponName)
    local weaponState = Core.Classes.Weapon.CurrentWeaponState()
    if not weaponState then return false end
    if weaponState.weapon ~= weaponName:lower() then return end
    Core.Classes.Weapon.Disarm()
end

-- Plays animation and waits a bit longer than the duration
---@param dictionary string
---@param animationName string
---@param duration? number
---@param enterSpeed? number
---@param exitSpeed? number
---@param delay? number
function Core.Classes.Weapon.PlayAnimation (dictionary, animationName, duration, enterSpeed, exitSpeed, delay)
    local ped = Core.Classes.Player.Ped()
    local pos = GetEntityCoords(ped, true)
    local heading = GetEntityHeading(ped)

    -- Loads the animation dictionary
    Core.Utilities.LoadAnimationDictionary(dictionary)

    -- Defaults
    duration = duration or 50
    enterSpeed = enterSpeed or 8.0
    exitSpeed = exitSpeed or 3.0
    delay = delay or 1000

    TaskPlayAnimAdvanced(
        ped, 
        dictionary, 
        animationName, 
        pos.x, pos.y, pos.z, 
        0, 0, heading, 
        enterSpeed, 
        exitSpeed, 
        -1, 
        duration, 
        0, 0, 0
    )

    -- Wait for x amount of time and clear tasks
    Wait(duration + delay)
    ClearPedTasks(ped)
end

-- Use weapon | Performs Equp or Disarm
---@param weaponData table
---@param canFire boolean
function Core.Classes.Weapon.Use (weaponData)

    -- Cease fire while equipping, disarming
    Core.Classes.Weapon.UpdateFireState(false)

    local weaponState = Core.Classes.Weapon.CurrentWeaponState()
    local ped = Core.Classes.Player.Ped()
    
    local weaponName = tostring(weaponData.name)
    local weaponHash = joaat(weaponData.name:upper())

    -- If the weapon is the same as current, Disarm
    -- If it is not, equip the weapon
    if weaponName == weaponState.weapon then
        Core.Classes.Weapon.Disarm()
    else
        if not Core.Classes.Weapon.Exists(weaponName:lower()) then
            return false
        end

        Core.Classes.Weapon.Equip(
            weaponData,
            Core.Utilities.TableHasValue(Config.Weapons.Throwables, weaponName:lower())
        )
    end

    -- Re-enable fire after tasks are done
    Core.Classes.Weapon.UpdateFireState(true)
end

-- Returns ammo from inventory if any
---@param ammoType string
---@return number
function Core.Classes.Weapon.InventoryAmmo (ammoType)
    if not ammoType then return 0 end

    if not Config.Weapons.AmmoItems[ammoType:upper()] then
        return 0
    end

    -- Get ammo item from inventory
    local items = Core.Classes.Inventory.FindItemsByName(Config.Weapons.AmmoItems[ammoType:upper()])

    -- Checks and balances
    if table.type(items) == "empty" then return 0 end
    local amount = 0

    -- For each stack count amount
    for _, item in pairs(items) do
        if item.name == Config.Weapons.AmmoItems[ammoType:upper()] then
            amount = amount + item.amount
        end
    end

    return amount
end

-- Disarms weapon
function Core.Classes.Weapon.Disarm (skipAnimation)
    local ped = Core.Classes.Player.Ped()
    local state = Core.Classes.Weapon:GetState()

    -- Check for animation
    if not skipAnimation then
        if state.currentWeapon then
            local animation = Core.Classes.Weapon.HasAnimation(state.currentWeapon, 'disarm')
            if not animation then animation = defaultAnimation.disarm end
            state.currentWeapon = nil
            if animation then
                Core.Classes.Weapon.PlayAnimation(
                    animation[1],
                    animation[2],
                    animation[3],
                    animation[4],
                    animation[5],
                    animation[6]
                )
            end
        end
    end

    -- Reset state and remove weapons
    Core.Classes.Weapon.ResetWeaponState()
    SetCurrentPedWeapon(ped, GetHashKey(UnarmedWeapon), true)
    RemoveAllPedWeapons(ped, true)

    Core.Utilities.Log({
        title = "Weapon.Disarm()",
        message = "Weapon has been disarmed"
    })
end

-- Equips weapon
function Core.Classes.Weapon.Equip (weaponData, isThrowable)
    local ammo = 0
    local weaponName = tostring(weaponData.name)
    local weaponHash = joaat(weaponData.name:upper())

    -- Check weapon quality
    if weaponData.info then
        if weaponData.info.quality ~= nil then
            if weaponData.info.quality == 0 then
                return false
            end
        end
    end

    -- Set ammo based on weapon type
    if isThrowable then
        ammo = 1
    else
        -- Check for ammo in inventory and set
        local inventoryAmmo = Core.Classes.Weapon.InventoryAmmo(weaponData.ammotype)
        if inventoryAmmo > 0 then
            ammo = inventoryAmmo
        end
    end

    -- Forced ammo amount override check
    if Config.Weapons.ForcedAmmoAmount[weaponName] then
        ammo = Config.Weapons.ForcedAmmoAmount[weaponName]
    end

    -- Check for animation
    if weaponName ~= UnarmedWeapon then
        local animation = Core.Classes.Weapon.HasAnimation(weaponName, 'equip')
        if not animation then animation = defaultAnimation.equip end

        if animation then
            Core.Classes.Weapon.PlayAnimation(
                animation[1],
                animation[2],
                animation[3],
                animation[4],
                animation[5],
                animation[6]
            )
        end
    end
    
    -- Give weapon and set ammo
    local ped = Core.Classes.Player.Ped()
    GiveWeaponToPed(ped, weaponHash, ammo, false, false)

    -- Handle attachments for weapon
    if weaponData.info then
        if weaponData.info.attachments then
            for _, attachment in pairs(weaponData.info.attachments) do
                if attachment.component then
                    GiveWeaponComponentToPed(ped, weaponHash, GetHashKey(attachment.component:upper()))
                end
            end
        end
    end

    -- Set active weapon for ped
    SetPedAmmo(ped, weaponHash, ammo)
    SetCurrentPedWeapon(ped, weaponHash, true)

    -- Update state
    Core.Classes.Weapon:UpdateState({
        currentWeapon = weaponName,
        currentWeaponData = weaponData,
        currentWeaponAmmo = GetAmmoInPedWeapon(ped, weaponHash)
    })

    Core.Utilities.Log({
        title = "Weapon.Equip()",
        message = ("%s has been equiped"):format(weaponName)
    })
end

-- Updates ped ammo for active weapon
function Core.Classes.Weapon.UpdatePedAmmo ()

    local ped = Core.Classes.Player.Ped()
    local weaponState = Core.Classes.Weapon.CurrentWeaponState()

    -- Checks and balances
    if not weaponState.weapon then return false end
    if not weaponState.data then return false end
    if not weaponState.data.ammotype then return false end

    -- Get ammo and set it
    local weaponHash = GetHashKey(weaponState.weapon:upper())
    local inventoryAmmo = Core.Classes.Weapon.InventoryAmmo(weaponState.data.ammotype)
    SetPedAmmo(ped, weaponHash, inventoryAmmo)
end

-- Returns if weapon should remove 1 of itself
---@param weaponName string
---@return boolean
function Core.Classes.Weapon.IsRemovable (weaponName)
    return Core.Utilities.TableHasValue(Config.Weapons.Removables, weaponName)
end

-- Checks data to remove and add items from ammo boxes
---@param itemRemove string
---@param itemGain string
function Core.Classes.Weapon.AmmoBoxes(itemRemove, itemGain)
    if not Framework.Client.Progressbar('Unpacking Box Of Ammo', 4000, 'picklock', { disable = {} }) then return end
    TriggerServerEvent(Config.ServerEventPrefix .. 'UseAmmoBox', itemRemove, itemGain)
end

-- Updates weapon ammo
---@param reload? boolean
function Core.Classes.Weapon.UpdateAmmo (reload)

    local ped = Core.Classes.Player.Ped()
    local weaponState = Core.Classes.Weapon.CurrentWeaponState()

    -- Checks and balances
    if not weaponState.weapon then return false end
    if not weaponState.data then return false end

    -- checks if melee weapon and if it is it returns true so it wont kick the weapon back to your pockets
    if Config.Weapons.Melee[weaponState.weapon] then return true end 

    -- If of forced ammo type, return false
    if Config.Weapons.ForcedAmmoAmount[weaponState.weapon] then return false end
    if Core.Classes.Weapon.InventoryAmmo(weaponState.data.ammotype) == 0 then  Core.Classes.Weapon.Disarm() weaponState.weapon = nil return end
    -- If no weapon ammo type, but is removable, make call
    if not weaponState.data.ammotype then 
        if Core.Classes.Weapon.IsRemovable(weaponState.weapon) then
            local res = lib.callback.await(Config.ServerEventPrefix .. 'UpdateWeaponAmmo', false, weaponState.data, 1)

            -- If response returns that disarm should happen
            if res.disarm == true then

                -- Set in a timeout to not disrupt animation for throwing
                SetTimeout(2000, function ()
                    Core.Classes.Weapon.Disarm(true)
                end)
            end

            return true
        else
            return false
        end
    end

    -- Get the clip size and call backend
    local weaponHash = GetHashKey(weaponState.weapon:upper())
    local clipSize = GetMaxAmmoInClip(ped, weaponHash, true)

    -- Calculations
    local inventoryAmmo = Core.Classes.Weapon.InventoryAmmo(weaponState.data.ammotype)
    local ammoInWeapon = GetAmmoInPedWeapon(ped, weaponHash)

    local _, ammoInClip = GetAmmoInClip(ped, weaponHash)

    -- Clip validation
    if ammoInClip == clipSize then return false end
    if ammoInClip > clipSize then return false end
    if ammoInClip < 0 then return false end

    if Core.Classes.Weapon:GetState('currentWeaponAmmo') == ammoInWeapon then return false end
    local ammo = (Core.Classes.Weapon:GetState('currentWeaponAmmo') - ammoInWeapon)
    Core.Classes.Weapon:UpdateState('currentWeaponAmmo', ammoInWeapon)

    -- Calls the backend and updates ammo total
    local res = lib.callback.await(Config.ServerEventPrefix .. 'UpdateWeaponAmmo', false, weaponState.data, ammo)

    -- If response returns that disarm should happen
    if res.disarm == true then
        Core.Classes.Weapon.Disarm()
    else

        -- If reloading, make ped reload and disable actions while reloading
        if reload == true then
            MakePedReload(ped)

            while IsPedReloading(ped) do
                Core.Utilities.DisableControlActions({
                    { 0, 22 },
                    { 0, 24 },
                    { 0, 45 }
                })
                Wait(0)
            end
        end
    end

    -- Update inventory and set ammo
    Core.Classes.Inventory.Update(function ()

        -- If a reload, update ped ammo
        if reload == true then
            Core.Classes.Weapon.UpdatePedAmmo()
        end
    end)
end

-- Checks weapon firing
function Core.Classes.Weapon.CheckFire()
    CreateThread(function()

        -- If canFire is false, disable control actions and firing
        while not Core.Classes.Weapon:GetState('canFire') do
            DisableControlAction(0, 25, true)
            DisablePlayerFiring(Core.Classes.Player.Ped(), true)
            Wait(0)
        end
    end)
end

-- Listens for shooting and updates ammo when needed
function Core.Classes.Weapon.ShotListener ()
    CreateThread(function()

        Core.Utilities.Log({
            title = "Weapon.ShotListener()",
            message = "Has started"
        })

        while true do
            local weaponState = Core.Classes.Weapon.CurrentWeaponState()
            if weaponState.weapon and weaponState.data then

                -- Update ammo when shooting
                if IsPedShooting(Core.Classes.Player.Ped()) or IsControlJustPressed(0, 24) then
                    Core.Classes.Weapon.UpdateAmmo(false)
                end
            end
            Wait(0)
        end
    end)
end

-- Modifies damage for a weapon if set in Config.Weapons.DamageModifier
function Core.Classes.Weapon.DamageModifier ()
    CreateThread(function()

        Core.Utilities.Log({
            title = "Weapon.DamageModifier()",
            message = "Has started"
        })

        while true do
            Wait(0)
            
            local ped = PlayerPedId()
            local weaponHash = GetSelectedPedWeapon(ped)

            if not weaponHash then
                Wait(500)
            else
                local weaponName = Core.Classes.Weapon.GetByHash(weaponHash)

                if weaponName then
                    local weaponDamageData = Config.Weapons.DamageModifier[weaponName]
                
                    if weaponDamageData then
                        if weaponDamageData.disableCritical then SetPedSuffersCriticalHits(ped, false) end
                        SetWeaponDamageModifier(weaponHash, weaponDamageData.modifier)
                    else
                        Wait(500)
                    end
                end
            end
        end
    end)
end

-- Exports
exports('UseWeapon',         Core.Classes.Weapon.Use)
exports('DisarmWeapon',      Core.Classes.Weapon.Disarm)
exports('ReloadWeapon',      Core.Classes.Weapon.Reload)
exports('WeaponAttachments', Core.Classes.Weapon.Attachments)
