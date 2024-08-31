-------------------------------------------------
--- Inventory Setup (Runs when server starts)
-------------------------------------------------

-- Creates the inventory class
Core.Classes.New("Player", { CurrentHealth = 100, Ped = nil })

-- Init player data
function Core.Classes.Player.Init ()
    local ped = PlayerPedId()

    Core.Classes.Player:UpdateStates({
        Ped = ped,
        CurrentHealth = GetEntityHealth(ped)
    })
end

-- Return player's current weapon
---@return number|nil
function Core.Classes.Player.Source ()
    return source
end

-- Return player's current weapon
---@return number|nil
function Core.Classes.Player.Ped ()
    return Core.Classes.Player:GetState('Ped')
end

-- Return player's current weapon
---@return table
function Core.Classes.Player.CurrentWeapon ()
    local ped = Core.Classes.Player:GetState('Ped')
    local weapon = GetSelectedPedWeapon(ped)
    local ammo = nil

    if weapon then 
        ammo = GetAmmoInPedWeapon(ped, weapon) 
    end

    return { weapon = weapon, ammo = ammo }
end

-- Resets the state for the class
function Core.Classes.Player.Reset ()
    local ped = Core.Classes.Player:GetState('Ped')
    Core.Classes.Player:UpdateState('CurrentHealth', GetEntityHealth(ped))
end

-- Gets current health for player
function Core.Classes.Player.GetHealth ()
    return Core.Classes.Player:GetState('CurrentHealth')
end

-- Updates the health for player
---@param updateInventory? boolean
function Core.Classes.Player.UpdateHealth (updateInventory)
    local ped = Core.Classes.Player:GetState('Ped')
    Core.Classes.Player:UpdateState('CurrentHealth', GetEntityHealth(ped))

    if updateInventory then
        Core.Classes.Player.PushUpdateToInventory()
    end
end

-- Sends update to inventory
function Core.Classes.Player.PushUpdateToInventory ()
    SendNUIMessage({
        action = "health",
        currentHealth = Core.Classes.Player.GetHealth()
    })
end