-------------------------------------------------
--- Process crafting queue every second
-------------------------------------------------
CreateThread(function ()
    while true do
        Core.Classes.Crafting.ProcessQueue()
        Wait(1000)
    end
end)