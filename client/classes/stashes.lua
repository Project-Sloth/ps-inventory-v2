-------------------------------------------------
--- Stashes Setup
-------------------------------------------------

-- Creates the stashes class
Core.Classes.New("Stashes", { nearStashId = false })

-------------------------------------------------
--- Loading for stashes
-------------------------------------------------
function Core.Classes.Stashes.Load ()
    if Config.UseTarget then

        for stashId, stash in pairs(Config.Stashes) do
            Framework.Client.AddBoxZone({
                id = 'stash-target-' .. stashId,
                location = stash.location,
                size = stash.size,
                options = {
                    {
                        label = stash.optionLabel or "Open " .. stash.name,
                        action = function ()
                            Core.Classes.Stashes.Open(stashId)
                        end,
                        canInteract = function ()
                            if stash.group then
                                if not Framework.Client.HasGroup(stash.group) then return false end 
                            end

                            return true
                        end
                    }
                }
            })
        end
    end
end

-------------------------------------------------
--- Dinstance checker for stashes
-------------------------------------------------
function Core.Classes.Stashes.DistanceCheck()
    local playerPos = GetEntityCoords(PlayerPedId())
    local shortestDistance = math.huge
    local requiredDistance = 4

    for stashId, stash in pairs(Config.Stashes) do
        -- Group check
        if stash.group then
            if not Framework.Client.HasGroup(stash.group) then goto continue end
        end

        local distance = #(playerPos - stash.location)

        if distance < shortestDistance then
            shortestDistance = distance
        end

        if distance <= (stash.radius or requiredDistance) then
            Core.Classes.Interact.Show('Press [<span class="active-color">' .. Config.InteractKey.Label .. '</span>] to access stash')
            Core.Classes.Stashes:UpdateState('nearStashId', stashId)

            while distance <= (stash.radius or requiredDistance) do
                Wait(100)
                playerPos = GetEntityCoords(PlayerPedId())
                distance = #(playerPos - stash.location)
            end

            Core.Classes.Interact.Hide()
            Core.Classes.Stashes:UpdateState('nearStashId', false)
        end

        ::continue::
    end

    Wait(100 + math.floor(shortestDistance * 10))
end

-------------------------------------------------
--- Open stash if near one
-------------------------------------------------
function Core.Classes.Stashes.Open(stashId)
    local stashId = Core.Classes.Stashes:GetState('nearStashId') or stashId

    if stashId then
        TriggerServerEvent(Config.ServerEventPrefix .. 'OpenStash', stashId)
    end
end