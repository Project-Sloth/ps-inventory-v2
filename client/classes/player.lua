-------------------------------------------------
--- Inventory Setup (Runs when server starts)
-------------------------------------------------

-- Creates the inventory class
Core.Classes.New("Player", { currentHealth = 100 })

-- Init player data
function Core.Classes.Player.Init ()
    Core.Classes.Player:UpdateState({
        Ped = PlayerPedId(),
        currentHealth = GetEntityHealth(PlayerPedId())
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
    return PlayerPedId()
end

-- Return player's current weapon
---@return table
function Core.Classes.Player.CurrentWeapon ()
    local weapon = GetSelectedPedWeapon(PlayerPedId())
    local ammo = nil

    if weapon then 
        ammo = GetAmmoInPedWeapon(PlayerPedId(), weapon) 
    end

    return { weapon = weapon, ammo = ammo }
end

-- Resets the state for the class
function Core.Classes.Player.Reset ()
    Core.Classes.Player:UpdateState('currentHealth', GetEntityHealth(PlayerPedId()))
end

-- Gets current health for player
function Core.Classes.Player.GetHealth ()
    return Core.Classes.Player:GetState('currentHealth')
end

-- Updates the health for player
---@param updateInventory? boolean
function Core.Classes.Player.UpdateHealth (updateInventory)
    Core.Classes.Player:UpdateState('currentHealth', GetEntityHealth(PlayerPedId()))

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