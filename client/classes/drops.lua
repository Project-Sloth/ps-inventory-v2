-------------------------------------------------
--- Drops Setup
-------------------------------------------------

-- Creates the drops class
Classes.New("Drops", { nearDropId = false, drops = {}, props = {} })

-------------------------------------------------
--- Updates the drops table
-------------------------------------------------
function Classes.Drops.UpdateDrops(drops)

    -- Iterate through drops that were removed in last beacon
    if type(drops.removed) == "table" then
        for _, dropId in pairs(drops.removed) do

            Utilities.Log({
                title = "Drops.Remove",
                message = "Processing removal of " .. dropId
            })

            Classes.Drops.RemoveProp(dropId)

            -- If they have the inventory open on this drop, close the drop
            if Classes.Inventory:GetState('IsOpen') then
                local externalData = Classes.Inventory:GetState('External')
                if externalData then
                    if externalData.type == "drop" and externalData.id == dropId then
                        Classes.Inventory.Close()
                    end
                end
            end

            if Classes.Drops:GetState('nearDropId') == dropId then
                Classes.Drops:UpdateState('nearDropId', dropId)
            end
        end
    end

    -- Iterate drops and update
    if drops.list then
        local props = Classes.Drops:GetState('props')

        if type(drops.list) == "table" then
            for k, drop in pairs(drops.list) do
                Classes.Drops.AddProp(drop.id, drop.location)
            end
        end

        Classes.Drops:UpdateState('drops', drops.list)
    end
end

-------------------------------------------------
--- Adds prop for drop if does not exist
-------------------------------------------------
function Classes.Drops.AddProp (dropId, location)
	local props = Classes.Drops:GetState('props')
    if not props[dropId] then
        local res = Utilities.CreateObject(Config.Drops.Prop, location)
        if res then
            props[dropId] = res.EntityId
        end
    end
    Classes.Drops:UpdateState('props', props)
end

-------------------------------------------------
--- Removes prop for drop if exists
-------------------------------------------------
function Classes.Drops.RemoveProp (dropId)
	local props = Classes.Drops:GetState('props')
    if props[dropId] then
        Utilities.DeleteEntity(props[dropId], 'object')
        props[dropId] = nil
    end
    Classes.Drops:UpdateState('props', props)
end

-------------------------------------------------
--- Creates a new drop
-------------------------------------------------
function Classes.Drops.Get (dropId)
	local drop = false

    for k, d in pairs(Classes.Drops:GetState('drops')) do
        if d.id == dropId then
            drop = d
        end
    end

    return drop
end

-------------------------------------------------
--- Returns nearDropId
-------------------------------------------------
function Classes.Drops.IsNearDrop ()
    local nearDrop = Classes.Drops:GetState('nearDropId')
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
function Classes.Drops.DistanceCheck()
    local playerPos = GetEntityCoords(PlayerPedId())
    local shortestDistance = math.huge
    local requiredDistance = 4

    for k, drop in pairs(Classes.Drops:GetState('drops')) do
        local distance = #(playerPos - drop.location)

        if distance < shortestDistance then
            shortestDistance = distance
        end

        if distance <= requiredDistance then
            Classes.Drops:UpdateState('nearDropId', drop.id)

            while distance <= requiredDistance do
                Wait(100)
                playerPos = GetEntityCoords(PlayerPedId())
                distance = #(playerPos - drop.location)
            end

            Classes.Drops:UpdateState('nearDropId', false)
        end
    end

    Wait(100 + math.floor(shortestDistance * 10))
end

-------------------------------------------------
--- Cleanup props on resourceStop
-------------------------------------------------
function Classes.Drops.Cleanup()
    local props = Classes.Drops:GetState('props')
    for _, prop in pairs(props) do Utilities.DeleteEntity(prop) end
end