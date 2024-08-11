-------------------------------------------------
--- Crating thread
-------------------------------------------------
CreateThread(function ()
    if not Core.Classes.Inventory:GetState('Loaded') then Wait(1000) end
    Core.Classes.Crafting.Load()

    if not Config.UseTarget and Config.Interact then
        while true do
            if not Core.Classes.Inventory:GetState('Loaded') then Wait(1000) end
            Core.Classes.Crafting.DistanceCheck()
        end
    end
end)

-------------------------------------------------
--- Crating open check
-------------------------------------------------
if not Config.UseTarget and Config.Interact then
    CreateThread(function ()
        while true do
            if IsControlJustPressed(0, Config.InteractKey.Code) or IsControlJustPressed(1, Config.InteractKey.Code) then
                Core.Classes.Crafting.Open()
            end
    
            Wait(0)
        end
    end)
end