-------------------------------------------------
--- Placeables Setup
-------------------------------------------------

-- Creates the placeables class
Core.Classes.New("Placeables", { props = {}, placementMode = false, nearPropId = false, zones = {} })

-------------------------------------------------
--- Loads placeables
-------------------------------------------------
function Core.Classes.Placeables.Load()
    local items = lib.callback.await(Config.ServerEventPrefix .. 'GetPlaceables', false)
    local props = Core.Classes.Placeables:GetState('props')

    if not items then return false end

    for id, item in pairs(items) do
        if not props[id] then
            local entity = Core.Classes.Placeables.Place(item.item, item.coords, item.heading, item.shouldSnapToGround, id)
            item.entity = entity
            props[id] = item
        end
    end

    Core.Classes.Placeables:UpdateState('props', props)
end

-------------------------------------------------
--- Adds target options if using target
-------------------------------------------------
function Core.Classes.Placeables.AttachTarget (propId, id, additionalOptions)

    local defaultOption = {
        action = function ()
            Core.Classes.Placeables.Pickup(id)
        end,
        icon = "fas fa-hand-holding",
        label = "Pick up"
    }

    local targetOptions = {}

    if type(additionalOptions) == "table" then
        for _, option in pairs(additionalOptions) do
            table.insert(targetOptions, option)
        end
    end

    table.insert(targetOptions, defaultOption)

    Framework.Client.AddTargetEntity(propId, {
        options = targetOptions,
        distance = 1.5
    })
end

-------------------------------------------------
--- Update placeables on next beacon received
-------------------------------------------------
function Core.Classes.Placeables.Update(items)
    local props = Core.Classes.Placeables:GetState('props')

    for id, prop in pairs(props) do
        if not items[id] then
            if prop.entity then Core.Classes.Placeables.RemoveObject(prop.entity) end
            Core.Classes.Placeables.RemoveZone(id)
            props[id] = nil
        end
    end

    for id, item in pairs(items) do
        if not props[id] then
            local entity = Core.Classes.Placeables.Place(item.item, item.coords, item.heading, item.shouldSnapToGround, id)
            item.entity = entity
            props[id] = item
        end
    end

    Core.Classes.Placeables:UpdateState('props', props)
end

-------------------------------------------------
--- Dinstance checker for placeables
-------------------------------------------------
function Core.Classes.Placeables.RotationToDirection(rotation)
    local adjustedRotation = {
        x = (math.pi / 180) * rotation.x,
        y = (math.pi / 180) * rotation.y,
        z = (math.pi / 180) * rotation.z
    }
    local direction = {
        x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        z = math.sin(adjustedRotation.x)
    }
    return direction
end

-------------------------------------------------
--- Dinstance checker for placeables
-------------------------------------------------
function Core.Classes.Placeables.RayCastGamePlayCamera(distance, object, raycastDetectWorldOnly)
    local cameraRotation = GetGameplayCamRot()
    local cameraCoord = GetGameplayCamCoord()
    local direction = Core.Classes.Placeables.RotationToDirection(cameraRotation)

    local destination = {
        x = cameraCoord.x + direction.x * distance,
        y = cameraCoord.y + direction.y * distance,
        z = cameraCoord.z + direction.z * distance
    }

    local traceFlag = 4294967295
    if raycastDetectWorldOnly then
        traceFlag = 1
    end

    local a, hit, coords, d, entity = GetShapeTestResult(StartShapeTestRay(
        cameraCoord.x, 
        cameraCoord.y, 
        cameraCoord.z, 
        destination.x, 
        destination.y, 
        destination.z, 
        traceFlag, 
        object, 
        0
    ))

    return hit, coords, entity
end

-------------------------------------------------
--- Dinstance checker for placeables
-------------------------------------------------
function Core.Classes.Placeables.Place(item, coords, heading, shouldSnapToGround, id)

    coords = vector3(coords.x, coords.y, coords.z)

    local ped = PlayerPedId()
    local itemName = item.item
    local itemModel = item.prop
    local shouldFreezeItem = item.isFrozen

    -- Cancel any active animation
    ClearPedTasks(ped)

    -- Stop playing the animation
    StopAnimTask(ped, animationDict, animation, 1.0)

    Core.Utilities.LoadModelHash(itemModel)

    local obj = CreateObject(itemModel, coords, true)
    if obj == 0 then return false end

    SetEntityRotation(obj, 0.0, 0.0, heading, false, false)
    SetEntityCoords(obj, coords)

    if shouldFreezeItem then
        FreezeEntityPosition(obj, true)
    end

    if shouldSnapToGround then
        PlaceObjectOnGroundProperly(obj)
    end

    Entity(obj).state:set('itemName', itemName, true)
    item.entity = obj
    item.location = coords

    SetModelAsNoLongerNeeded(itemModel)

    if Config.UseTarget then
        local options = {}

        if item.interactType then
            table.insert(options, {
                action = function ()
                    Core.Classes.Placeables.Open(id)
                end,
                icon = "fas fa-eye",
                label = "Access " .. item.interactType
            })
        end

        Core.Classes.Placeables.AttachTarget(obj, id, options)
    else
        Core.Classes.Placeables.AddZone(id, lib.zones.sphere({
            coords = vector3(item.location.x, item.location.y, item.location.z),
            radius = 3,
            debug = false,
            onEnter = function ()
                local interactType = ""
                if item.interactType then
                    interactType = 'Press [<span class="active-color">' .. Config.InteractKey.Label .. '</span>] to access ' .. item.interactType .. '<br />'
                end

                Core.Classes.Interact.Show(interactType .. 'Press [<span class="active-color">SHIFT + E</span>] to pickup')
                Core.Classes.Placeables:UpdateState('nearPropId', id)
            end,
            onExit = function ()
                Core.Classes.Interact.Hide()
                Core.Classes.Placeables:UpdateState('nearPropId', false)
            end
        }))
    end

    return obj
end

function Core.Classes.Placeables.Save(item, coords, heading, shouldSnapToGround)
    local payload = {
        item = item,
        coords = coords,
        heading = heading,
        shouldSnapToGround = shouldSnapToGround
    }

    local res = lib.callback.await(Config.ServerEventPrefix .. 'SavePlaceable', false, payload)
    lib.callback.await(Config.ServerEventPrefix .. 'RemoveItem', false, item)
end

-------------------------------------------------
--- Places item
-------------------------------------------------
function Core.Classes.Placeables.PlacementMode(item)
    if not item.prop then return false end
    if Core.Classes.Placeables:GetState('placementMode') then return false end

    -- Load the model
    Core.Utilities.LoadModelHash(item.prop)

    -- Setting placement mode to true
    Core.Classes.Placeables:UpdateState('placementMode', true)

    -- Get ped 
    local ped = PlayerPedId()

    -- Create the object
    local CreatedObject = CreateObject(item.prop, GetEntityCoords(ped), false, false)
    SetEntityAlpha(CreatedObject, 150, false)
    SetEntityCollision(CreatedObject, false, false)

    local zOffset = 0
    local raycastDetectWorldOnly = true

    -- Do the placement logic in this loop
    while Core.Classes.Placeables:GetState('placementMode') do
        local hit, coords, entity = Core.Classes.Placeables.RayCastGamePlayCamera(Config.Placeables.ItemPlacementModeRadius, CreatedObject, raycastDetectWorldOnly)

        -- Move the object to the coords from the raycast
        SetEntityCoords(CreatedObject, coords.x, coords.y, coords.z + zOffset)

        -- Handle various key presses and actions

        -- Controls for placing item

        -- Pressed Shift + E - Place object on ground
        if IsControlJustReleased(0, 38) and IsControlPressed(0, 21)then
            Core.Classes.Placeables:UpdateState('placementMode', false)

            local objHeading = GetEntityHeading(CreatedObject)
            local snapToGround = true

            Core.Classes.Placeables.Save(item, vector3(coords.x, coords.y, coords.z + zOffset), objHeading, snapToGround)
            DeleteEntity(CreatedObject)

        -- Pressed E - Place object at current position
        elseif IsControlJustReleased(0, 38) then
            Core.Classes.Placeables:UpdateState('placementMode', false)

            local objHeading = GetEntityHeading(CreatedObject)
            local snapToGround = false

            Core.Classes.Placeables.Save(item, vector3(coords.x, coords.y, coords.z + zOffset), objHeading, snapToGround)
            DeleteEntity(CreatedObject)
        end

        -- Controls for rotating item

        -- Mouse Wheel Up (and Shift not pressed), rotate by +10 degrees
        if IsControlJustReleased(0, 241) and not IsControlPressed(0, 21) then
            local objHeading = GetEntityHeading(CreatedObject)
            SetEntityRotation(CreatedObject, 0.0, 0.0, objHeading + 10, false, false)
        end

        -- Mouse Wheel Down (and shift not pressed), rotate by -10 degrees
        if IsControlJustReleased(0, 242) and not IsControlPressed(0, 21) then
            local objHeading = GetEntityHeading(CreatedObject)
            SetEntityRotation(CreatedObject, 0.0, 0.0, objHeading - 10, false, false)
        end

        -- Controls for raising/lowering item

        -- Shift + Mouse Wheel Up, move item up
        if IsControlPressed(0, 21) and IsControlJustReleased(0, 241) then
            zOffset = zOffset + 0.1
            if zOffset > Config.Placeables.maxZOffset then
                zOffset = Config.Placeables.maxZOffset
            end
        end

        -- Shift + Mouse Wheel Down, move item down
        if IsControlPressed(0, 21) and IsControlJustReleased(0, 242) then
            zOffset = zOffset - 0.1
            if zOffset < Config.Placeables.minZOffset then
                zOffset = Config.Placeables.minZOffset
            end
        end

        -- Mouse Wheel Click, change placement mode
        if IsControlJustReleased(0, 348) then
            raycastDetectWorldOnly = not raycastDetectWorldOnly
        end

        -- Right click or Backspace to exit out of placement mode and delete the local object
        if IsControlJustReleased(0, 177) then
            Core.Classes.Placeables:UpdateState('placementMode', false)
            DeleteEntity(CreatedObject)
        end

        Wait(1)
    end
end

-------------------------------------------------
--- Open shop if near one
-------------------------------------------------
function Core.Classes.Placeables.Open(propId)
    if not Core.Classes.Placeables:GetState('nearPropId') and not propId then return false end
    local item = Core.Classes.Placeables:GetState('props')[Core.Classes.Placeables:GetState('nearPropId') or propId]
    if not item then return false end

    if item.item.eventType then
        if item.item.eventType == 'client' then
            TriggerEvent(item.item.eventName, item.item.eventParams or nil)
        elseif item.item.eventType == 'server'then
            TriggerServerEvent(item.item.eventName, item.item.eventParams or nil)
        end
    end
end

-------------------------------------------------
--- Picks up item
-------------------------------------------------
function Core.Classes.Placeables.Pickup(propId)
    local ped = PlayerPedId()
    if not Core.Classes.Placeables:GetState('nearPropId') and not propId then return false end
    local itemData = Core.Classes.Placeables:GetState('props')[Core.Classes.Placeables:GetState('nearPropId') or propId]
    local itemEntity = itemData.entity
    local itemModel = itemData.item.prop
    local itemName = Entity(itemEntity).state.prop or itemData.item.prop

    if itemName then
        -- Cancel any active animation
        ClearPedTasks(ped)

        -- Show pickup as a progress
        Framework.Client.Progressbar("pickup_item", "Picking up item", 200, false, true, {
            disableMovement = false,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = animationDict,
            anim = animation,
            flags = 0,
        }, nil, nil, function() -- Done
            -- Stop playing the animation
            StopAnimTask(ped, animationDict, animation, 1.0)

            -- Add the item to the inventory
            lib.callback.await(Config.ServerEventPrefix .. 'AddItem', false, itemData.item)

            -- Remove the object
            local coords = GetEntityCoords(itemEntity)
            Core.Classes.Placeables.RemoveObject(itemEntity)
            Core.Classes.Placeables.RemoveZone(propId)

            -- Delete object server-side
            lib.callback.await(Config.ServerEventPrefix .. 'RemovePlaceable', false, Core.Classes.Placeables:GetState('nearPropId') or propId)

            -- Hide interaction text
            Core.Classes.Interact.Hide()
        end, function() -- Cancel
            StopAnimTask(ped, animationDict, animation, 1.0)
            Notify("Canceled..", "error")
        end)
    end
end

-------------------------------------------------
--- Removes object
-------------------------------------------------
function Core.Classes.Placeables.RemoveObject (itemEntity)
    local netId = NetworkGetNetworkIdFromEntity(itemEntity)
    Core.Classes.Placeables.RequestNetworkControlOfObject(netId, itemEntity)
    SetEntityAsMissionEntity(itemEntity, true, true)
    DeleteEntity(itemEntity)
end

-------------------------------------------------
--- Get control of network object
-------------------------------------------------
function Core.Classes.Placeables.RequestNetworkControlOfObject(netId, itemEntity)
    if NetworkDoesNetworkIdExist(netId) then
        NetworkRequestControlOfNetworkId(netId)
        while not NetworkHasControlOfNetworkId(netId) do
            Wait(100)
            NetworkRequestControlOfNetworkId(netId)
        end
    end

    if DoesEntityExist(itemEntity) then
        NetworkRequestControlOfEntity(itemEntity)
        while not NetworkHasControlOfEntity(itemEntity) do
            Wait(100)
            NetworkRequestControlOfEntity(itemEntity)
        end
    end
end

-------------------------------------------------
--- Adds new zone
-------------------------------------------------
function Core.Classes.Placeables.AddZone(id, zone)
    local zones = Core.Classes.Placeables:GetState('zones')
    if zones[id] then
        if zones[id] ~= nil then
            zones[id]:remove()
        end
    end

    zones[id] = zone
    Core.Classes.Placeables:GetState('zones', zones)
end

-------------------------------------------------
--- Removes existing zone
-------------------------------------------------
function Core.Classes.Placeables.RemoveZone(id)
    local zones = Core.Classes.Placeables:GetState('zones')

    if zones[id] then
        if zones[id] ~= nil then
            zones[id]:remove()
            zones[id] = nil
            Core.Classes.Placeables:GetState('zones', zones)
        end
    end
end