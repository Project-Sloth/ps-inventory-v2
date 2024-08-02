-------------------------------------------------
--- Drops distance check
-------------------------------------------------
if not Config.UseTarget and Config.Interact then
    CreateThread(function ()
        while true do
            if not Classes.Inventory:GetState('Loaded') then Wait(1000) end
            Classes.Drops.DistanceCheck()
        end
    end)
end