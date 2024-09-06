-------------------------------------------------
--- Placeables Setup
-------------------------------------------------

-- Creates the placeables class
Core.Classes.New("Placeables", { props = {}, placementMode = false, nearPropId = false, zones = {} })

-- Loads placeables
function Core.Classes.Placeables.Load()
    local items = lib.callback.await(Config.ServerEventPrefix .. 'GetPlaceables', false)
    local props = Core.Classes.Placeables:GetState('props')

    if not items then return false end

    for id, item in pairs(items) do
        if not props[id] then
            if Core.Classes.Placeables.Place(item.item, item.coords, item.heading, item.shouldSnapToGround, id) then
                props[id] = item
            end
        end
    end

    Core.Classes.Placeables:UpdateState('props', props)
end

-- Adds target options if using target
---@param propId number
---@param id number
---@param additionalOptions? table
function Core.Classes.Placeables.AttachTarget (propId, id, additionalOptions)

    local defaultOption = {
        action = function ()
            Core.Classes.Placeables.Pickup(id)
        end,
        icon = "fas fa-hand-holding",
        label = Core.Language.Locale('placeablesPickupTarget')
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
        distance = Config.Placeables.Radius or 1.5
    })
end

-- Update placeables on next beacon received
---@param items table
function Core.Classes.Placeables.Update(items)
    local props = Core.Classes.Placeables:GetState('props')

    for id, prop in pairs(props) do
        if not items[id] then
            if prop.entity then Core.Classes.Placeables.RemoveObject(id) end
            Core.Classes.Placeables.RemoveZone(id)
            props[id] = nil
        end
    end

    for id, item in pairs(items) do
        if not props[id] then

            if Core.Classes.Placeables.Place(item.item, item.coords, item.heading, item.shouldSnapToGround, id) then
                props[id] = item
            end
        end
    end

    Core.Classes.Placeables:UpdateState('props', props)
end

-- Dinstance checker for placeables
---@param rotation vector3
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

-- Dinstance checker for placeables
---@param distance number
---@param object table
function Core.Classes.Placeables.RayCastGamePlayCamera(distance, object)
    local cameraRotation = GetGameplayCamRot()
    local cameraCoord = GetGameplayCamCoord()
    local direction = Core.Classes.Placeables.RotationToDirection(cameraRotation)

    local destination = {
        x = cameraCoord.x + direction.x * distance,
        y = cameraCoord.y + direction.y * distance,
        z = cameraCoord.z + direction.z * distance
    }

    local a, hit, coords, d, entity = GetShapeTestResult(StartShapeTestRay(
        cameraCoord.x, 
        cameraCoord.y, 
        cameraCoord.z, 
        destination.x, 
        destination.y, 
        destination.z, 
        1, 
        object, 
        0
    ))

    return hit, coords, entity
end

-- Dinstance checker for placeables
---@param item table
---@param coords table
---@param heading number
---@param shouldSnapToGround boolean
---@param id number
function Core.Classes.Placeables.Place(item, coords, heading, shouldSnapToGround, id)
    if not item.placeable then return false end

    -- Generate the ped id
    local propId = ("placeable__%s"):format(id)

    -- Register the ped in the spawn manager
    Core.SpawnManager.Register('object', {
        id = propId,
        isNetwork = false,
        prop = item.placeable.prop,
        location = vector3(coords.x, coords.y, coords.z),
        onCreate = function ()
            coords = vector3(coords.x, coords.y, coords.z)

            local ped = PlayerPedId()
            local itemName = item.item
            local itemModel = item.placeable.prop
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

                if item.placeable.option then
                    table.insert(options, {
                        action = function ()
                            Core.Classes.Placeables.Open(id)
                        end,
                        icon = item.placeable.option.icon,
                        label = item.placeable.option.label
                    })
                end

                Core.Classes.Placeables.AttachTarget(obj, id, options)
            else
                Core.Classes.Placeables.AddZone(id, lib.zones.sphere({
                    coords = vector3(item.location.x, item.location.y, item.location.z),
                    radius = Config.Placeables.Radius or 3,
                    debug = false,
                    onEnter = function ()
                        local interactType = ""
                        if item.placeable.option then
                            interactType = Core.Language.Locale('placeablesInteractType', {
                                key = Config.InteractKey.Label,
                                interactType = item.placeable.option.label
                            })
                        end

                        Core.Classes.Interact.Show(interactType .. Core.Language.Locale('placeablesPickup'))
                        Core.Classes.Placeables:UpdateState('nearPropId', id)
                    end,
                    onExit = function ()
                        Core.Classes.Interact.Hide()
                        Core.Classes.Placeables:UpdateState('nearPropId', false)
                    end
                }))
            end

            return {
                entityId = obj,
                networkId = NetworkGetNetworkIdFromEntity(obj)
            }
        end
    })

    return propId
end

-- Sends item to server to save
---@param item table
---@param coords table
---@param heading number
---@param shouldSnapToGround boolean
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

-- Places item
---@param item table
function Core.Classes.Placeables.PlacementMode(item)
    if not item.placeable then return false end
    if not item.placeable.prop then return false end
    if Core.Classes.Placeables:GetState('placementMode') then return false end

    -- Load the model
    Core.Utilities.LoadModelHash(item.placeable.prop)

    -- Setting placement mode to true
    Core.Classes.Placeables:UpdateState('placementMode', true)

    -- Get ped 
    local ped = PlayerPedId()

    -- Create the object
    local CreatedObject = CreateObject(item.placeable.prop, GetEntityCoords(ped), false, false)
    SetEntityAlpha(CreatedObject, 150, false)
    SetEntityCollision(CreatedObject, false, false)

    local zOffset = 0

    -- Do the placement logic in this loop
    while Core.Classes.Placeables:GetState('placementMode') do

        -- Get keys to show for interaction
        local keys = {
            Core.Language.Locale('placeablesPlace', {
                key = 'E'
            }),
            Core.Language.Locale('placeablesRotate', {
                key = 'Mouse Wheel'
            }),
            Core.Language.Locale('placeablesCancel', {
                key = 'Backspace'
            })
        }

        -- Append interaction keys
        local interactionText = ""
        for _, text in pairs(keys) do
            interactionText = interactionText .. text
        end

        -- Show interaction
        Core.Classes.Interact.Show(keys)

        -- Get raycast data
        local hit, coords, entity = Core.Classes.Placeables.RayCastGamePlayCamera(Config.Placeables.ItemPlacementModeRadius, CreatedObject)

        -- Move the object to the coords from the raycast
        SetEntityCoords(CreatedObject, coords.x, coords.y, coords.z + zOffset)

        -- E = Place object
        if IsControlJustReleased(0, 38) then
            Core.Classes.Placeables:UpdateState('placementMode', false)

            local objHeading = GetEntityHeading(CreatedObject)
            local snapToGround = false

            Core.Classes.Placeables.Save(item, vector3(coords.x, coords.y, coords.z + zOffset), objHeading, snapToGround)
            DeleteEntity(CreatedObject)

            Core.Classes.Interact.Hide()
        end

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

        -- Right click or Backspace to exit out of placement mode and delete the local object
        if IsControlJustReleased(0, 177) then
            Core.Classes.Placeables:UpdateState('placementMode', false)
            DeleteEntity(CreatedObject)
            Core.Classes.Interact.Hide()
        end

        Wait(1)
    end
end

-- Open shop if near one
---@param propId number
function Core.Classes.Placeables.Open(propId)
    if not Core.Classes.Placeables:GetState('nearPropId') and not propId then return false end
    local item = Core.Classes.Placeables:GetState('props')[Core.Classes.Placeables:GetState('nearPropId') or propId]
    if not item then return false end

    if item.item.placeable.option then
        if item.item.placeable.option.event then
            if item.item.placeable.option.event.type then
                if item.item.placeable.option.event.type == "client" then
                    TriggerEvent(
                        Config.ClientEventPrefix .. item.item.placeable.option.event.name, 
                        item.item.placeable.option.event.params or nil
                    )
                elseif item.item.placeable.option.event.type == "server" then
                    TriggerServerEvent(
                        Config.ServerEventPrefix .. item.item.placeable.option.event.name, 
                        item.item.placeable.option.event.params or nil
                    )
                end
            end
        end
    end
end

-- Picks up item
---@param propId number
-- Picks up item
---@param propId number
function Core.Classes.Placeables.Pickup(propId)
    local ped = PlayerPedId()
    if not Core.Classes.Placeables:GetState('nearPropId') and not propId then return false end
    local itemData = Core.Classes.Placeables:GetState('props')[Core.Classes.Placeables:GetState('nearPropId') or propId]

    -- Get item data from spawn manager
    local spawnedItemKey, spawnedItemData = Core.SpawnManager.Get('object', ("placeable__%s"):format(propId))
    if not spawnedItemKey then return false end

    local itemEntity = spawnedItemData.entityId
    local itemModel = itemData.item.placeable.prop
    local itemName = Entity(itemEntity).state.prop or itemData.item.placeable.prop

    if itemName then
        -- Cancel any active animation
        ClearPedTasks(ped)

        -- Show pickup as a progress
        if not Framework.Client.Progressbar(Core.Language.Locale('placeablesPickingUp'), 
        (itemData.item.placeable.pickupTime and itemData.item.placeable.pickupTime * 1000 or Config.Placeables.PickupTime * 1000), 'pickup',{disable = {}}) then return end
        
        lib.callback.await(Config.ServerEventPrefix .. 'AddItem', false, itemData.item)

        -- Remove the object
        local coords = GetEntityCoords(itemEntity)
        Core.Classes.Placeables.RemoveObject(propId)
        Core.Classes.Placeables.RemoveZone(propId)

        -- Delete object server-side
        lib.callback.await(Config.ServerEventPrefix .. 'RemovePlaceable', false, Core.Classes.Placeables:GetState('nearPropId') or propId)

        -- Hide interaction text
        Core.Classes.Interact.Hide()
    end
end


-- Removes object
---@param itemEntity number
function Core.Classes.Placeables.RemoveObject (id)
    local propId = ("placeable__%s"):format(id)
    Core.SpawnManager.Remove('object', propId)
end

-- Adds new zone
---@param id string
---@param zone CZone
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

-- Removes existing zone
---@param id string
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
