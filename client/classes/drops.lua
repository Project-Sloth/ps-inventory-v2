-------------------------------------------------
--- Drops Setup
-------------------------------------------------

-- Creates the drops class
Core.Classes.New("Drops", { nearDropId = false, drops = {}, props = {} })

-------------------------------------------------
--- Updates the drops table
-------------------------------------------------
function Core.Classes.Drops.UpdateDrops(drops)

    -- Iterate through drops that were removed in last beacon
    if type(drops.removed) == "table" then
        for _, dropId in pairs(drops.removed) do

            Core.Utilities.Log({
                title = "Drops.Remove",
                message = "Processing removal of " .. dropId
            })

            Core.Classes.Drops.RemoveProp(dropId)

            -- If they have the inventory open on this drop, close the drop
            if Core.Classes.Inventory:GetState('IsOpen') then
                local externalData = Core.Classes.Inventory:GetState('External')
                if externalData then
                    if externalData.type == "drop" and externalData.id == dropId then
                        Core.Classes.Inventory.Close()
                    end
                end
            end

            if Core.Classes.Drops:GetState('nearDropId') == dropId then
                Core.Classes.Drops:UpdateState('nearDropId', dropId)
            end
        end
    end

    -- Iterate drops and update
    if drops.list then
        local props = Core.Classes.Drops:GetState('props')

        if type(drops.list) == "table" then
            for k, drop in pairs(drops.list) do
                Core.Classes.Drops.AddProp(drop.id, drop.location)
            end
        end

        Core.Classes.Drops:UpdateState('drops', drops.list)
    end
end

-------------------------------------------------
--- Adds prop for drop if does not exist
-------------------------------------------------
function Core.Classes.Drops.AddProp (dropId, location)
	local props = Core.Classes.Drops:GetState('props')
    if not props[dropId] then
        local res = Core.Utilities.CreateObject(Config.Drops.Prop, location)
        if res then
            props[dropId] = res.EntityId
        end
    end
    Core.Classes.Drops:UpdateState('props', props)
end

-------------------------------------------------
--- Removes prop for drop if exists
-------------------------------------------------
function Core.Classes.Drops.RemoveProp (dropId)
	local props = Core.Classes.Drops:GetState('props')
    if props[dropId] then
        Core.Utilities.DeleteEntity(props[dropId], 'object')
        props[dropId] = nil
    end
    Core.Classes.Drops:UpdateState('props', props)
end

-------------------------------------------------
--- Creates a new drop
-------------------------------------------------
function Core.Classes.Drops.Get (dropId)
	local drop = false

    for k, d in pairs(Core.Classes.Drops:GetState('drops')) do
        if d.id == dropId then
            drop = d
        end
    end

    return drop
end

-------------------------------------------------
--- Returns nearDropId
-------------------------------------------------
function Core.Classes.Drops.IsNearDrop ()
    local nearDrop = Core.Classes.Drops:GetState('nearDropId')
    if not nearDrop then return false end

    return {
        type = "drop",
        id = nearDrop,
        name = "Drop",
    }
end

-------------------------------------------------
--- Distance checker for drops
-------------------------------------------------
function Core.Classes.Drops.DistanceCheck()
    local playerPos = GetEntityCoords(PlayerPedId())
    local shortestDistance = math.huge
    local requiredDistance = 4

    for k, drop in pairs(Core.Classes.Drops:GetState('drops')) do
        local distance = #(playerPos - drop.location)

        if distance < shortestDistance then
            shortestDistance = distance
        end

        if distance <= requiredDistance then
            Core.Classes.Drops:UpdateState('nearDropId', drop.id)

            while distance <= requiredDistance do
                Wait(100)
                playerPos = GetEntityCoords(PlayerPedId())
                distance = #(playerPos - drop.location)
            end

            Core.Classes.Drops:UpdateState('nearDropId', false)
        end
    end

    Wait(100 + math.floor(shortestDistance * 10))
end

-------------------------------------------------
--- Cleanup props on resourceStop
-------------------------------------------------
function Core.Classes.Drops.Cleanup()
    local props = Core.Classes.Drops:GetState('props')
    for _, prop in pairs(props) do Core.Utilities.DeleteEntity(prop) end
end