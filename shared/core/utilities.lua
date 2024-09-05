if not Core then Core = {} end

Core.Utilities = {

    -- General logging method
    ---@param data table
    Log = function(data)
        if type(data) ~= "table" then return end
        if not data.title then return end
        if not data.message then return end
        if not data.type then data.type = "info" end

        -- If console debugging is enabled
        if Config.Debugging or data.force then
            if data.type == 'error' then
                print(("^1[%s] %s: %s^0"):format(data.type, data.title, data.message))
            elseif data.type == 'warning' then
                print(("^3[%s] %s: %s^0"):format(data.type, data.title, data.message))
            elseif data.type == 'success' then
                print(("^2[%s] %s: %s^0"):format(data.type, data.title, data.message))
            else
                print(("[%s] %s: %s"):format(data.type, data.title, data.message))
            end
        end

        -- Process fm-logs
        if Config.Logging['fm-logs'] then
            if GetResourceState('fm-logs') ~= "missing" then
                exports['fm-logs']:createLog({
                    Resource = GetCurrentResourceName(),
                    LogType = data.title,
                    Message = data.message,
                    Level = data.type,
                })
            end
        end
    end,

    -- Loads file in resource
    ---@param filePath string
    LoadFile = function (filePath)

        local file = LoadResourceFile(GetCurrentResourceName(), filePath)

        if not file then
            Core.Utilities.Log({
                type = "error",
                title = "Utilities.LoadFile",
                message = "Unable to load " .. filePath
            })

            return false
        end

        local fileContent, err = load(file)
        if fileContent then 
            Core.Utilities.Log({
                type = "success",
                title = "Utilities.LoadFile",
                message = "Loaded " .. filePath
            })

            fileContent() 
            return true
        end

        Core.Utilities.Log({
            type = "error",
            title = "Utilities.LoadFile",
            message = "Unable to load " .. filePath
        })

        return false
    end,

    -- Register an export event handler
    ---@param resourceName string
    ---@param exportName string
    ---@param func function
    ExportHandler = function (resourceName, exportName, func)
        Core.Utilities.Log({
            title = "Core.Utilities.ExportHandler",
            message = ('Registering export handler: __cfx_export_%s_%s'):format(resourceName, exportName)
        })

        AddEventHandler(('__cfx_export_%s_%s'):format(resourceName, exportName), function(setCallback)
            setCallback(func)
        end)
    end,

    -- Merges two tables together
    ---@param a table
    ---@param b table
    MergeTables = function (a, b)
        if type(a) == 'table' and type(b) == 'table' then
            for k, v in pairs(b) do 
                a[k] = v 
            end
        end

        return a
    end,

    -- Get table length
    ---@param tbl table
    TableLength = function (tbl)
        local l = 0
        for n in pairs(tbl) do 
            l = l + 1 
        end
        return l
    end,

    -- Checks a table to see if a key exists
    ---@param t table
    ---@param key any
    TableContainsKey = function (t, key)
        local keyExists = false

        for k, _ in pairs(t) do
            if (k == key) then
                keyExists = true
            end
        end

        return keyExists
    end,

    -- Checks if a table has value
    ---@param t table
    ---@param value any
    TableHasValue  = function (t, value)
        local hasValue = false

        for _, v in pairs(t) do
            if (v == value) then
                hasValue = true
            end
        end

        return hasValue
    end,

    -- Generate random string with length
    ---@param length number
    RandomString = function (length)
        local charset = {}  do
            for c = 48, 57  do table.insert(charset, string.char(c)) end
            for c = 65, 90  do table.insert(charset, string.char(c)) end
            for c = 97, 122 do table.insert(charset, string.char(c)) end
        end
        
        if not length or length <= 0 then return '' end
        return Core.Utilities.RandomString(length - 1) .. charset[math.random(1, #charset)]
    end,

    -- Generate random number with length
    ---@param length number
    RandomNumber = function (length)
        local charset = {} do
            for i = 48, 57 do table.insert(charset, string.char(i)) end
        end

        if not length or length <= 0 then return '' end
        return Core.Utilities.RandomNumber(length - 1) .. charset[math.random(1, #charset)]
    end,

    -- Generate a new serial number
    GenerateSerialNumber = function ()
        return tostring(Core.Utilities.RandomNumber(2) .. Core.Utilities.RandomString(3) ..
                        Core.Utilities.RandomNumber(1) .. Core.Utilities.RandomString(2) ..
                        Core.Utilities.RandomNumber(3) .. Core.Utilities.RandomString(4))
    end,

    -- Generate a new drop id
    GenerateDropId = function ()
        return tostring(Core.Utilities.RandomNumber(4) .. Core.Utilities.RandomString(4) ..
                        Core.Utilities.RandomNumber(2) .. Core.Utilities.RandomString(4) ..
                        Core.Utilities.RandomNumber(2) .. Core.Utilities.RandomString(4))
    end,

    -- Generate a new queue id
    GenerateQueueId = function ()
        return tostring(Core.Utilities.RandomNumber(4) .. Core.Utilities.RandomString(4) ..
                        Core.Utilities.RandomNumber(2) .. Core.Utilities.RandomString(4) ..
                        Core.Utilities.RandomNumber(2) .. Core.Utilities.RandomString(4))
    end,

    -- Disables multiple keys
    -- { { 0, 22}, ... }
    ---@param keys table
    DisableControlActions = function (keys)
        for _, key in pairs(keys) do
            DisableControlAction(key[1], key[2], true)
        end
    end,

    -- Loads an animation dictionary
    LoadAnimationDictionary = function (dict)
        if HasAnimDictLoaded(dict) then return end
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Wait(10)
        end
    end,

    -- Loads a model hash
    ---@param ModelHash string
    LoadModelHash = function (ModelHash)
        local modelHash = GetHashKey(ModelHash)
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do
            Wait(1)
        end
    end,

    -- Checks against config for if vehicle has a back engine
    ---@param hashKey number
    VehicleIsBackEngine = function (hashKey)
        local isBackEngine = false

        for model, val in pairs(Config.Vehicles.BackEngine) do
            if GetHashKey(model) == hashKey then
                if val == true then
                    isBackEngine = true
                end
            end
        end

        return isBackEngine
    end,

    -- Creates a blip
    ---@param settings table
    ---@param coords vector3|table
    CreateBlip = function (settings, coords)
        AddTextEntry('TEST', settings.name)
        local blip = AddBlipForCoord(coords)
        SetBlipSprite(blip, settings.sprite)
        SetBlipColour(blip, settings.color)
        SetBlipScale(blip, settings.scale or 0.7)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('TEST')
        AddTextComponentSubstringPlayerName(settings.name)
        EndTextCommandSetBlipName(blip)
        SetBlipDisplay(blip, 3)
        return blip
    end,

    -- Creates an object
    ---@param prop string
    ---@param location vector3|table
    CreateObject = function (isNetwork, prop, location)
        Core.Utilities.Log({
            title = "Core.Utilities.CreateObject",
            message = ("Creating object with model %s"):format(prop)
        })

        Core.Utilities.LoadModelHash(prop)
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
            EntityId = CreatedObject,
            EntityNetworkId = networkId
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
        Core.Utilities.Log({
            title = "Core.Utilities.CreatePed",
            message = ("Creating ped with model %s"):format(modelHash)
        })

        Core.Utilities.LoadModelHash(modelHash)

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
            EntityId = CreatedPed,
            EntityNetworkId = networkId
        }
    end,

    -- Delets a network ped by entity id
    ---@param Entity number
    ---@param type string
    DeleteEntity = function (entity, entType)
        if type(entity) ~= "table" then
            return Core.Utilities.Log({
                title = "Core.Utilities.DeleteEntity",
                message = "Parameter 1 must be of type table"
            })
        end

        -- Request control of entity if network id is available
        if entity.EntityNetworkId then
            Core.Utilities.RequestNetworkControlOfObject(entity.EntityNetworkId, entity.EntityId, true)
        end

        -- Check if it exists first
        if DoesEntityExist(entity.EntityId) then 
            if entType == "object" then
                DeleteEntity(entity.EntityId)
            else
                DeletePed(entity.EntityId)
            end
        else
            Core.Utilities.Log({
                title = "Core.Utilities.DeleteEntity",
                message = "Unable to find entity: " .. entity.EntityId
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