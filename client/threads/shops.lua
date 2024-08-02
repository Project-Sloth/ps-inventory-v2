-------------------------------------------------
--- Shops thread
-------------------------------------------------
CreateThread(function ()
    if not Classes.Inventory:GetState('Loaded') then Wait(1000) end
    Classes.Shops.Load()

    while true do
        if not Classes.Inventory:GetState('Loaded') then Wait(1000) end
        Classes.Shops.DistanceCheck()
    end
end)

-------------------------------------------------
--- Shops open check
-------------------------------------------------
if not Config.UseTarget and Config.Interact then
    CreateThread(function ()
        while true do
            if IsControlJustPressed(0, Config.InteractKey.Code) or IsControlJustPressed(1, Config.InteractKey.Code) then
                Classes.Shops.Open()
            end
    
            Wait(0)
        end
    end)
end