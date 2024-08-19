-------------------------------------------------
--- Inventory Setup (Runs when server starts)
-------------------------------------------------

-- Creates the inventory class
Core.Classes.New("Player", { CurrentHealth = 100 })

function Core.Classes.Player.Reset ()
    Core.Classes.Player:UpdateState('CurrentHealth', GetEntityHealth(PlayerPedId()))
end

-- Get current damages
function Core.Classes.Player.GetHealth ()
    return Core.Classes.Player:GetState('CurrentHealth')
end

-- Update player damages by group
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