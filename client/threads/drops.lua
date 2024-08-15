-------------------------------------------------
--- Drops distance check
-------------------------------------------------
CreateThread(function ()
    while true do
        if not Core.Classes.Inventory:GetState('Loaded') then Wait(1000) end
        Core.Classes.Drops.DistanceCheck()
    end
end)