-------------------------------------------------
--- Shop distance check
-------------------------------------------------
CreateThread(function ()
    while true do
        if not Classes.Inventory:GetState('Loaded') then Wait(1000) end
        Classes.Vehicles.DistanceCheck()
    end
end)