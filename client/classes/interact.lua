-------------------------------------------------
--- Interact Setup
-------------------------------------------------

-- Creates the interact class
Classes.New("Interact")

-- Adds item in NUI
function Classes.Interact.Show(message)
    SendNUIMessage({
        action = "interact",
        process = "show",
        message = message
    })
end

-- Removes item in NUI
function Classes.Interact.Hide()
    SendNUIMessage({
        action = "interact",
        process = "hide",
    })
end