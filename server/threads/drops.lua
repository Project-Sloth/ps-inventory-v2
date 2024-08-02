-------------------------------------------------
--- Thread for clearing expired drops
-------------------------------------------------

Utilities.Log({
    title = "Drops.ClearExpired",
    message = "Thread is running every " .. Config.Drops.ExpirationTime .. " seconds"
})

CreateThread(function ()
    while true do
        Wait(Config.Drops.ExpirationTime * 1000)
        Classes.Drops.ClearExpired()
    end
end)