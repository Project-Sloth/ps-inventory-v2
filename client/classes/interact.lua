-------------------------------------------------
--- Interact Setup
-------------------------------------------------

-- Creates the interact class
Core.Classes.New("Interact")

-- Adds item in NUI
---@param message string
function Core.Classes.Interact.Show(message)
    SendNUIMessage({
        action = "interact",
        process = "show",
        message = message
    })
end

-- Removes item in NUI
function Core.Classes.Interact.Hide()
    SendNUIMessage({
        action = "interact",
        process = "hide",
    })
end