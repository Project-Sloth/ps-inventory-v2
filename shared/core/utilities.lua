Utilities = {

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
            print("[" .. data.type .. "] " .. data.title .. ": " .. data.message)
        end

        -- Place other log logic here
    end,

    -- Loads a resource file
    LoadFile = function (lib, file)
        local success, result = pcall(lib.load, file)

        if not success then
            Utilities.Log({
                title = "Unable to load file",
                message = "Loading of " .. file .. " failed."
            })
        else
            Utilities.Log({
                title = "Loaded file",
                message = "Loading of " .. file .. " succeeded."
            })
        end

        return { success = success, result = result }
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

    -- Generate random string with length
    RandomString = function (length)
        local charset = {}  do
            for c = 48, 57  do table.insert(charset, string.char(c)) end
            for c = 65, 90  do table.insert(charset, string.char(c)) end
            for c = 97, 122 do table.insert(charset, string.char(c)) end
        end
        
        if not length or length <= 0 then return '' end
        return Utilities.RandomString(length - 1) .. charset[math.random(1, #charset)]
    end,

    -- Generate random number with length
    RandomNumber = function (length)
        local charset = {} do
            for i = 48, 57 do table.insert(charset, string.char(i)) end
        end

        if not length or length <= 0 then return '' end
        return Utilities.RandomNumber(length - 1) .. charset[math.random(1, #charset)]
    end,

    -- Generate a new serial number
    GenerateSerialNumber = function ()
        return tostring(Utilities.RandomNumber(2) .. Utilities.RandomString(3) ..
                        Utilities.RandomNumber(1) .. Utilities.RandomString(2) ..
                        Utilities.RandomNumber(3) .. Utilities.RandomString(4))
    end,

    -- Generate a new drop id
    GenerateDropId = function ()
        return tostring(Utilities.RandomNumber(4) .. Utilities.RandomString(4) ..
                        Utilities.RandomNumber(2) .. Utilities.RandomString(4) ..
                        Utilities.RandomNumber(2) .. Utilities.RandomString(4))
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
        Utilities.LoadModelHash(prop)
        local CreatedObject = CreateObjectNoOffset(prop, location.x, location.y, location.z, 1, 0, 1)
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
        SetBlipSprite(blip, settings.blip)
        SetBlipColour(blip, settings.color)
        SetBlipScale(blip, 0.7)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('TEST')
        AddTextComponentSubstringPlayerName(settings.name)
        EndTextCommandSetBlipName(blip)
        SetBlipDisplay(blip, 3)
    end,

    -- Creates a ped and returns information
    CreateNetworkPed = function (modelHash, x, y, z, heading)
        Utilities.LoadModelHash(modelHash)

        local CreatedPed = CreatePed(4, modelHash , x, y, z, heading, true, true)
        FreezeEntityPosition(CreatedPed, true)
	    SetEntityInvincible(CreatedPed, true)
        SetBlockingOfNonTemporaryEvents(CreatedPed, true)
	    TaskStartScenarioInPlace(CreatedPed, "", 0, true)
        while not DoesEntityExist(CreatedPed) do Citizen.Wait(10) end

        return {
            NetworkId = NetworkGetNetworkIdFromEntity(CreatedPed),
            EntityId = CreatedPed
        }
    end,

    -- Delets a network ped by entity id
    DeleteEntity = function (Entity, type)

        -- Check if it exists first
        if DoesEntityExist(Entity) then 
            if type == "object" then
                Utilities.Log({
                    title = "Utilities.DeleteEntity",
                    message = "Processing removal of " .. Entity
                })

                DeleteEntity(Entity)
            else
                DeletePed(Entity)
            end
        else
            Utilities.Log({
                title = "Utilities.DeleteEntity",
                message = "Unable to find entity: " .. Entity
            })
        end
    end,
}