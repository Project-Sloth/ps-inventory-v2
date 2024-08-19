-- Handles interactions for inventory
RegisterNetEvent(Config.ClientEventPrefix .. 'Interact', function (action, message)
    if action == "show" then
        Core.Classes.Interact.Show(message)
    elseif action == "hide" then
        Core.Classes.Interact.Hide()
    end
end)