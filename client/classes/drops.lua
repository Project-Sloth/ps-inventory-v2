-------------------------------------------------
--- Drops Setup
-------------------------------------------------

-- Creates the drops class
Core.Classes.New("Drops", { nearDropId = false, drops = {}, props = {}, zones = {} })

-- Updates the drops table
---@param drops table
function Core.Classes.Drops.UpdateDrops(drops)

    -- Iterate through drops that were removed in last beacon
    if type(drops.removed) == "table" then
        for _, dropId in pairs(drops.removed) do

            Core.Utilities.Log({
                title = "Drops.Remove",
                message = "Processing removal of " .. dropId
            })

            Core.Classes.Drops.RemoveProp(dropId)
            Core.Classes.Drops.RemoveZone(dropId)

            -- If they have the inventory open on this drop, close the drop
            if Core.Classes.Inventory:GetState('IsOpen') then
                local externalData = Core.Classes.Inventory:GetState('External')
                if externalData then
                    if externalData.type == "drop" and externalData.id == dropId then
                        Core.Classes.Inventory.Open({
                            external = false
                        })
                    end
                end

                if Core.Classes.Drops:GetState('nearDropId') == dropId then
                    Core.Classes.Inventory.Open({
                        external = false
                    })
                end
            end

            if Core.Classes.Drops:GetState('nearDropId') == dropId then
                Core.Classes.Drops:UpdateState('nearDropId', false)
            end
        end
    end

    -- Iterate drops and update
    if drops.list then
        local props = Core.Classes.Drops:GetState('props')

        if type(drops.list) == "table" then
            for k, drop in pairs(drops.list) do
                Core.Classes.Drops.AddProp(drop.id, drop.location)
                Core.Classes.Drops.AddZone(drop.id, lib.zones.sphere({
                    coords = drop.location,
                    radius = Config.Drops.Radius or 4,
                    debug = false,
                    onEnter = function ()
                        Core.Classes.Drops:UpdateState('nearDropId', drop.id)
                    end,
                    onExit = function ()
                        Core.Classes.Drops:UpdateState('nearDropId', false)
                    end
                }))
            end
        end

        Core.Classes.Drops:UpdateState('drops', drops.list)
    end
end

-- Adds prop for drop if does not exist
---@param dropId number
---@param location vector3
function Core.Classes.Drops.AddProp (dropId, location)
	local props = Core.Classes.Drops:GetState('props')

    if not props[dropId] then
        -- Generate the ped id
        local propId = ("drop__%s"):format(dropId)

        -- Register the ped in the spawn manager
        Core.SpawnManager.Register('object', {
            id = propId,
            isNetwork = false,
            prop = Config.Drops.Prop,
            location = location
        })

        props[dropId] = propId
    end

    Core.Classes.Drops:UpdateState('props', props)
end

-- Removes prop for drop if exists
---@param dropId number
function Core.Classes.Drops.RemoveProp (dropId)
	local props = Core.Classes.Drops:GetState('props')
    if props[dropId] then
        Core.SpawnManager.Remove('object', props[dropId])
        props[dropId] = nil
    end
    Core.Classes.Drops:UpdateState('props', props)
end

-- Creates a new drop
---@param dropId number
function Core.Classes.Drops.Get (dropId)
	local drop = false

    for k, d in pairs(Core.Classes.Drops:GetState('drops')) do
        if d.id == dropId then
            drop = d
        end
    end

    return drop
end

-- Returns nearDropId
---@return table|boolean
function Core.Classes.Drops.IsNearDrop ()
    local nearDrop = Core.Classes.Drops:GetState('nearDropId')
    if not nearDrop then return false end

    return {
        type = "drop",
        id = nearDrop,
        name = "Drop",
    }
end

-- Adds new zone
---@param id string
---@param zone CZone
function Core.Classes.Drops.AddZone(id, zone)
    local zones = Core.Classes.Drops:GetState('zones')
    if zones[id] then
        if zones[id] ~= nil then
            zones[id]:remove()
        end
    end

    zones[id] = zone
    Core.Classes.Drops:GetState('zones', zones)
end

-- Removes existing zone
---@param id string
function Core.Classes.Drops.RemoveZone(id)
    local zones = Core.Classes.Drops:GetState('zones')

    if zones[id] then
        if zones[id] ~= nil then
            zones[id]:remove()
            zones[id] = nil
            Core.Classes.Drops:GetState('zones', zones)
        end
    end
end

-- Cleanup props on resourceStop
function Core.Classes.Drops.Cleanup()
    local zones = Core.Classes.Crafting:GetState("zones")
    for id, zone in pairs(zones) do Core.Classes.Drops.RemoveZone(id) end
end