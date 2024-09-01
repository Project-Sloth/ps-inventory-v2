-------------------------------------------------
--- Stashes Setup
-------------------------------------------------

-- Creates the stashes class
Core.Classes.New("Stashes", { nearStashId = false, zones = {} })

-- Loading for stashes
function Core.Classes.Stashes.Load ()
    for stashId, stash in pairs(Config.Stashes) do
        if Config.UseTarget then
            Framework.Client.AddBoxZone({
                id = 'stash-target-' .. stashId,
                location = stash.location,
                size = stash.size,
                options = {
                    {
                        label = stash.optionLabel or Core.Language.Locale('stashTarget', {
                            stashName = stash.name
                        }),
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
        else
            Core.Classes.Stashes.AddZone(stashId, lib.zones.sphere({
                coords = stash.location,
                radius = stash.radius or 3,
                debug = false,
                onEnter = function ()
                    -- Group check
                    if stash.group then
                        if not Framework.Client.HasGroup(stash.group) then return end
                    end
    
                    Core.Classes.Interact.Show(Core.Language.Locale('stashInteractive', {
                        key = Config.InteractKey.Label
                    }))

                    Core.Classes.Stashes:UpdateState('nearStashId', stashId)
                end,
                onExit = function ()
                    Core.Classes.Interact.Hide()
                    Core.Classes.Stashes:UpdateState('nearStashId', false)
                end
            }))
        end
    end
end

-- Adds new zone
---@param id string
---@param zone CZone
function Core.Classes.Stashes.AddZone(id, zone)
    local zones = Core.Classes.Stashes:GetState('zones')
    if zones[id] then
        if zones[id] ~= nil then
            zones[id]:remove()
        end
    end

    zones[id] = zone
    Core.Classes.Stashes:GetState('zones', zones)
end

-- Removes existing zone
---@param id string
function Core.Classes.Stashes.RemoveZone(id)
    local zones = Core.Classes.Stashes:GetState('zones')

    if zones[id] then
        if zones[id] ~= nil then
            zones[id]:remove()
            zones[id] = nil
            Core.Classes.Stashes:GetState('zones', zones)
        end
    end
end

-- Open stash if near one
---@param stashId string
function Core.Classes.Stashes.Open(stashId)
    local stashId = Core.Classes.Stashes:GetState('nearStashId') or stashId
    if stashId then
        Core.Utilities.Log({
            title = "Stashes.Open()",
            message = "Attempting to open " .. stashId
        })

        TriggerServerEvent(Config.ServerEventPrefix .. 'OpenStash', stashId)
    end
end

-- Cleanup on resourceStop
function Core.Classes.Stashes.Cleanup()
    local zones = Core.Classes.Stashes:GetState("zones")
    for id, zone in pairs(zones) do Core.Classes.Stashes.RemoveZone(id) end
end