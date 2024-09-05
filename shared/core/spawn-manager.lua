if not Core then Core = {} end

-- Spawns objects and peds when in range
Core.SpawnManager = {

    Enabled  = true,
    Distance = 200,
    Items    = {  ped = {}, object = {} },

    -- Called on resource stop, will remove all items
    OnResourceStop = function ()
        Core.SpawnManager.Enabled = false

        Core.Utilities.Log({
            title = "SpawnManager",
            message = "Thread has stopped, deleting all items"
        })

        for itemType, items in pairs(Core.SpawnManager.Items) do
            for key, item in pairs(items) do
                if item.entityId or item.networkId then

                    if item.target then
                        Framework.Client.RemoveTargetEntity(item.entityId)
                    end

                    Core.SpawnManager.DeleteEntity(item, itemType)
                end
            end
        end
    end,

    -- Starts the thread to check items to spawn within distance
    Thread = function ()
        Core.Utilities.Log({
            title = "SpawnManager",
            message = "Thread is running"
        })

        CreateThread(function()
            while Core.SpawnManager.Enabled do
                Wait(500)

                local playerCoords = GetEntityCoords(PlayerPedId())
			    
                for type, items in pairs(Core.SpawnManager.Items) do
                    for key, item in pairs(items) do
                        local inDistance = Core.SpawnManager.InDistance(item.location)

                        if inDistance and not item.rendered then
                            Core.Utilities.Log({
                                title = "SpawnManager",
                                message = ("%s[%s] is in range, spawning"):format(type, item.id)
                            })

                            Core.SpawnManager.Spawn(type, item)
                        end

                        if not inDistance and item.rendered then
                            Core.Utilities.Log({
                                title = "SpawnManager",
                                message = ("%s[%s] is out of range, despawning"):format(type, item.id)
                            })

                            Core.SpawnManager.Despawn(type, item)
                        end
                    end
                end
            end
        end)
    end,

    -- Spawns item based on type
    ---@param itemType string
    ---@param data table
    ---@return boolean
    Spawn = function (itemType, data)
        if itemType == 'ped' then

            local entity = type(data.onCreate) == 'function' and data.onCreate() or Core.SpawnManager.CreatePed(
                data.isNetwork,
                data.modelHash,
                data.location.x,
                data.location.y,
                data.location.z - 1,
                data.heading,
                data.scenario
            )

            if entity.entityId and data.target then
                Framework.Client.AddTargetEntity(entity.entityId, data.target)
            end

            return Core.SpawnManager.Update(itemType, data.id, {
                rendered = true,
                entityId = entity.entityId,
                networkId = entity.networkId
            })
            
        elseif itemType == 'object' then

            local entity = type(data.onCreate) == 'function' and data.onCreate() or Core.SpawnManager.CreateObject(
                data.isNetwork,
                data.prop,
                data.location
            )

            if entity.entityId and data.target then
                Framework.Client.AddTargetEntity(entity.entityId, data.target)
            end

            return Core.SpawnManager.Update(itemType, data.id, {
                rendered = true,
                entityId = entity.entityId,
                networkId = entity.networkId
            })
            
        else 
            Core.Utilities.Log({
                type = "error",
                title = "SpawnManager",
                message = "Invalid type supplied to Spawn()"
            })

            return false
        end
    end,

    -- Despawns item based on type
    ---@param type string
    ---@param data table
    Despawn = function (type, data)
        if data.entityId or data.networkId then

            if data.target then
                Framework.Client.RemoveTargetEntity(data.entityId)
            end

            Core.SpawnManager.DeleteEntity(data, type)
        end

        Core.SpawnManager.Update(type, data.id, {
            rendered = false,
            entityId = nil,
            networkId = nil
        })
    end,

    -- Checks if location is within distance of player
    ---@param location vector3|vector4|table
    ---@param radius number
    InDistance = function (location, radius)
        local playerCoords = GetEntityCoords(PlayerPedId())

        if type(location) ~= "vector3" and type(location) ~= "vector4" and type(location) ~= "table" then
            Core.Utilities.Log({
                type = "error",
                title = "SpawnManager",
                message = "Invalid coordinates type supplied for InDistance()"
            })
            return false
        end

        if not location.x or not location.y or not location.z then
            Core.Utilities.Log({
                type = "error",
                title = "SpawnManager",
                message = "Invalid coordinates type supplied for InDistance()"
            })
            return false
        end

        local coords = vec3(location.x, location.y, location.z)
        local distance = #(playerCoords - coords)

        if distance < Core.SpawnManager.Distance then return true end
        return false
    end,

    -- Registers a new item
    ---@param type string
    ---@param data table
    ---@return boolean
    Register = function (type, data)
        if not type then return false end
        if not data then return false end
        if not data.id then return false end
        if Core.SpawnManager.Get(type, data.id) then return false end
        data.rendered = false
        table.insert(Core.SpawnManager.Items[type], data)
        return true
    end,

    -- Updates item
    ---@param type string
    ---@param id string
    ---@param data table
    ---@return boolean
    Update = function (type, id, data)
        if not type then return false end
        if not id then return false end
        local itemKey, itemData = Core.SpawnManager.Get(type, id)
        if not itemKey then return false end
        
        for k, v in pairs(data) do
            itemData[k] = v
        end

        Core.SpawnManager.Items[type][itemKey] = itemData
        return true
    end,

    -- Removes item
    ---@param type string
    ---@param id string
    ---@return boolean
    Remove = function (type, id)
        if not type then return false end
        if not id then return false end
        local itemKey, itemData = Core.SpawnManager.Get(type, id)
        if not itemKey then return false end

        -- Delete if rendered
        if itemData.entityId or itemData.networkId or itemData.rendered then
            if itemData.target then
                Framework.Client.RemoveTargetEntity(itemData.entityId)
            end

            Core.SpawnManager.DeleteEntity(itemData, type)
        end

        table.remove(Core.SpawnManager.Items[type], itemKey)
        return true
    end,

    -- Gets item key and data
    ---@param type
    ---@param id string
    Get = function (type, id)
        if not type then return false end
        if not id then return false end
        if not Core.SpawnManager.Items[type] then return false end

        for key, item in pairs(Core.SpawnManager.Items[type]) do
            if item.id == id then return key, item end
        end

        return false
    end,

    -- Loads a model hash
    ---@param ModelHash string
    LoadModelHash = function (model)
        local modelHash = GetHashKey(model)
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do
            Wait(1)
        end
    end,

    -- Creates an object
    ---@param prop string
    ---@param location vector3|table
    CreateObject = function (isNetwork, prop, location)
        Core.SpawnManager.LoadModelHash(prop)
        local CreatedObject = CreateObjectNoOffset(prop, location.x, location.y, location.z, isNetwork, 0, 1)
        while not DoesEntityExist(CreatedObject) do Wait(10) end

        if location.w then
            SetEntityHeading(CreatedObject, location.w)
        end

        PlaceObjectOnGroundProperly(CreatedObject)
        FreezeEntityPosition(CreatedObject, true)
        SetModelAsNoLongerNeeded(CreatedObject)

        local networkId = nil
        if isNetwork then
            networkId = ObjToNet(CreatedObject)
        end

        return {
            entityId = CreatedObject,
            entityNetworkId = networkId
        }
    end,

    -- Creates a ped and returns information
    ---@param isNetwork boolean
    ---@param modelHash string
    ---@param x number
    ---@param y number
    ---@param z number
    ---@param heading number
    ---@param scenario string
    CreatePed = function (isNetwork, modelHash, x, y, z, heading, scenario)
        Core.SpawnManager.LoadModelHash(modelHash)

        local CreatedPed = CreatePed(4, modelHash , x, y, z, heading, isNetwork, isNetwork)
        while not DoesEntityExist(CreatedPed) do Wait(10) end

        FreezeEntityPosition(CreatedPed, true)
	    SetEntityInvincible(CreatedPed, true)
        SetBlockingOfNonTemporaryEvents(CreatedPed, true)

        if scenario then
            TaskStartScenarioInPlace(CreatedPed, scenario, 0, true)
        else
            TaskStartScenarioInPlace(CreatedPed, "", 0, true)
        end

        local networkId = nil
        if isNetwork then
            networkId = PedToNet(CreatedPed)
        end

        return {
            entityId = CreatedPed,
            entityNetworkId = networkId
        }
    end,

    -- Delets a network ped by entity id
    ---@param Entity number
    ---@param type string
    DeleteEntity = function (entity, entType)
        if type(entity) ~= "table" then
            return Core.Utilities.Log({
                title = "Core.SpawnManager.DeleteEntity",
                message = "Parameter 1 must be of type table"
            })
        end

        -- Request control of entity if network id is available
        if entity.networkId then
            Core.SpawnManager.RequestNetworkControlOfObject(entity.networkId, entity.entityId, true)
        end

        -- Check if it exists first
        if DoesEntityExist(entity.entityId) then 
            if entType == "object" then
                DeleteEntity(entity.entityId)
            else
                DeletePed(entity.entityId)
            end
        else
            Core.Utilities.Log({
                title = "Core.Utilities.DeleteEntity",
                message = "Unable to find entity: " .. entity.entityId
            })
        end
    end,

    -- Requests network control of network entity
    ---@param netId number
    ---@param entityId number
    RequestNetworkControlOfObject = function (netId, entityId, setMissionEntity)
        if NetworkDoesNetworkIdExist(netId) then
            NetworkRequestControlOfNetworkId(netId)
            while not NetworkHasControlOfNetworkId(netId) do
                Wait(100)
                NetworkRequestControlOfNetworkId(netId)
            end
        end

        if DoesEntityExist(entityId) then
            NetworkRequestControlOfEntity(entityId)
            while not NetworkHasControlOfEntity(entityId) do
                Wait(100)
                NetworkRequestControlOfEntity(entityId)
            end
        end

        if setMissionEntity then
            SetEntityAsMissionEntity(entityId, true, true)
        end
    end
}