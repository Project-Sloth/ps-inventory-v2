-------------------------------------------------
--- Stashes Setup
-------------------------------------------------

-- Creates the stashes class
Classes.New("Stashes", { nearStashId = false })

-------------------------------------------------
--- Dinstance checker for stashes
-------------------------------------------------
function Classes.Stashes.DistanceCheck()
    local playerPos = GetEntityCoords(PlayerPedId())
    local shortestDistance = math.huge
    local requiredDistance = 4

    for stashId, stash in pairs(Config.Stashes) do
        local distance = #(playerPos - stash.location)

        if distance < shortestDistance then
            shortestDistance = distance
        end

        if distance <= requiredDistance then
            Classes.Interact.Show('Press [<span class="active-color">' .. Config.InteractKey.Label .. '</span>] to access stash')
            Classes.Stashes:UpdateState('nearStashId', stashId)

            while distance <= requiredDistance do
                Wait(100)
                playerPos = GetEntityCoords(PlayerPedId())
                distance = #(playerPos - stash.location)
            end

            Classes.Interact.Hide()
            Classes.Stashes:UpdateState('nearStashId', false)
        end
    end

    Wait(100 + math.floor(shortestDistance * 10))
end

-------------------------------------------------
--- Open stash if near one
-------------------------------------------------
function Classes.Stashes.Open()
    local stashId = Classes.Stashes:GetState('nearStashId')

    if stashId then
        TriggerServerEvent(Config.ServerEventPrefix .. 'OpenStash', stashId)
    end
end