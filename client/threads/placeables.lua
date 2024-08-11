-------------------------------------------------
--- Placeables thread
-------------------------------------------------
CreateThread(function ()
    if not Core.Classes.Inventory:GetState('Loaded') then Wait(1000) end
    Core.Classes.Placeables.Load()

    if not Config.UseTarget and Config.Interact then
        while true do
            Core.Classes.Placeables.DistanceCheck()
        end
    end
end)

-------------------------------------------------
--- Crating open check
-------------------------------------------------
if not Config.UseTarget and Config.Interact then
    CreateThread(function ()
        while true do
            if IsControlJustPressed(0, 38) and IsControlPressed(0, 21) then
                Core.Classes.Placeables.Pickup()
            elseif IsControlJustPressed(0, 38) then
                Core.Classes.Placeables.Open()
            end
    
            Wait(0)
        end
    end)
end