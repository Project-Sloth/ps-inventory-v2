-------------------------------------------------
--- Stashes distance check
-------------------------------------------------

CreateThread(function ()
    if not Core.Classes.Inventory:GetState('Loaded') then Wait(1000) end
    Core.Classes.Stashes.Load()

    if not Config.UseTarget and Config.Interact then
        while true do
            Core.Classes.Stashes.DistanceCheck()
        end
    end
end)

-------------------------------------------------
--- Stashes open check
-------------------------------------------------
if not Config.UseTarget and Config.Interact then
    CreateThread(function ()
        while true do
            if IsControlJustPressed(0, Config.InteractKey.Code) or IsControlJustPressed(1, Config.InteractKey.Code) then
                Core.Classes.Stashes.Open()
            end
            Wait(0)
        end
    end)
end