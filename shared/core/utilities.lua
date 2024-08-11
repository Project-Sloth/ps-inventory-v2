Core.Utilities = {

    -- General logging method
    Log = function(data)
        if type(data) ~= "table" then return end

        if not data.title then
            return 
        end

        if not data.message then
            return
        end

        if not data.type then data.type = "info" end
        if Config.Debugging then
            print((data.type == 'error' and "^1" or "") .. "[" .. data.type .. "] " .. data.title .. ": " .. data.message .. (data.type == 'error' and "^0" or ""))
        end
    end,

    -- Loads file in resource
    LoadFile = function (filePath)
        local file = LoadResourceFile(GetCurrentResourceName(), filePath)

        if not file then
            Core.Utilities.Log({
                title = "Utilities.LoadFile",
                message = "Unable to load " .. filePath
            })

            return false
        end

        local fileContent, err = load(file)
        if fileContent then 
            Core.Utilities.Log({
                title = "Utilities.LoadFile",
                message = "Loaded " .. filePath
            })
            return fileContent() 
        end

        Core.Utilities.Log({
            title = "Utilities.LoadFile",
            message = "Unable to load " .. filePath
        })
    end,

    -- Register an export event handler
    ExportHandler = function (resourceName, exportName, func)
        print("Registering export handler: " .. ('__cfx_export_%s_%s'):format(resourceName, exportName))
        AddEventHandler(('__cfx_export_%s_%s'):format(resourceName, exportName), function(setCallback)
            setCallback(func)
        end)
    end,

    -- Get table length
    TableLength = function (tbl)
        local l = 0
        for n in pairs(tbl) do 
            l = l + 1 
        end
        return l
    end,

    -- Checks a table to see if a key exists
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

    -- Loads a model hash
    LoadModelHash = function (ModelHash)
        local modelHash = GetHashKey(ModelHash)
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do
            Wait(1)
        end
    end,

    -- Creates an object
    CreateObject = function (prop, location)
        Core.Utilities.LoadModelHash(prop)
        local CreatedObject = CreateObjectNoOffset(prop, location.x, location.y, location.z, 1, 0, 1)

        if location.w then
            SetEntityHeading(CreatedObject, location.w)
        end

        PlaceObjectOnGroundProperly(CreatedObject)
        FreezeEntityPosition(CreatedObject, true)
        SetModelAsNoLongerNeeded(CreatedObject)
        while not DoesEntityExist(CreatedObject) do Citizen.Wait(10) end

        return {
            EntityId = CreatedObject
        }
    end,

    -- Creates a blip
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

    -- Creates a ped and returns information
    CreateNetworkPed = function (modelHash, x, y, z, heading, scenario)
        Core.Utilities.LoadModelHash(modelHash)

        local CreatedPed = CreatePed(4, modelHash , x, y, z, heading, false, true)
        FreezeEntityPosition(CreatedPed, true)
	    SetEntityInvincible(CreatedPed, true)
        SetBlockingOfNonTemporaryEvents(CreatedPed, true)

        if scenario then
            TaskStartScenarioInPlace(CreatedPed, scenario, 0, true)
        else
            TaskStartScenarioInPlace(CreatedPed, "", 0, true)
        end
	    
        while not DoesEntityExist(CreatedPed) do Citizen.Wait(10) end

        return {
            EntityId = CreatedPed
        }
    end,

    -- Delets a network ped by entity id
    DeleteEntity = function (Entity, type)

        print("Deleting entity " .. Entity .. " of type " .. (type and type or 'ped'))

        -- Check if it exists first
        if DoesEntityExist(Entity) then 
            if type == "object" then
                Core.Utilities.Log({
                    title = "Core.Utilities.DeleteEntity",
                    message = "Processing removal of " .. Entity
                })

                DeleteEntity(Entity)
            else
                DeletePed(Entity)
            end
        else
            Core.Utilities.Log({
                title = "Core.Utilities.DeleteEntity",
                message = "Unable to find entity: " .. Entity
            })
        end
    end,
}