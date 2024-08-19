-------------------------------------------------
--- Inventory Setup (Runs when server starts)
-------------------------------------------------

-- Creates the inventory class
Core.Classes.New("Player", { CurrentHealth = 100 })

-- Resets the state for the class
function Core.Classes.Player.Reset ()
    Core.Classes.Player:UpdateState('CurrentHealth', GetEntityHealth(PlayerPedId()))
end

-- Gets current health for player
function Core.Classes.Player.GetHealth ()
    return Core.Classes.Player:GetState('CurrentHealth')
end

-- Updates the health for player
---@param updateInventory? boolean
function Core.Classes.Player.UpdateHealth (updateInventory)
    Core.Classes.Player:UpdateState('CurrentHealth', GetEntityHealth(PlayerPedId()))

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