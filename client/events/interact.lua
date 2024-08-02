-------------------------------------------------
--- Handles interactions for inventory
-------------------------------------------------
RegisterNetEvent(Config.ClientEventPrefix .. 'Interact', function (action, message)
    if action == "show" then
        Classes.Interact.Show(message)
    elseif action == "hide" then
        Classes.Interact.Hide()
    end
end)