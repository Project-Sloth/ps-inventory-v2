-- Get core object
Framework.GetCoreObject = function()
    return {}
end

-- Sends NUI a message
---@param data table
---@param updateInventory? boolean
Framework.Client.SendNUIMessage = function(data, updateInventory)
    SendNUIMessage(data)

    -- Update the inventory data
    if updateInventory then
        Core.Classes.Inventory.Update()
    end
end

-- Get player name
Framework.Client.GetPlayerName = function()
    return GetPlayerName(source)
end

-- Get player identifier
Framework.Client.GetPlayerIdentifier = function()
    return source
end

-- Get player cash
Framework.Client.GetPlayerCash = function()
    return 0
end

-- Can open inventory
Framework.Client.CanOpenInventory = function()
    return false
end

-- Has Group
---@param group table
Framework.Client.HasGroup = function(group)
    return false
end

-- Progress bar
Framework.Client.Progressbar = function(text, time, anim, data)
    TriggerEvent('animations:client:EmoteCommandStart', {anim})
    if Config.Progressbar == 'oxbar' then
        if lib.progressBar({
            duration = time,
            label = text,
            useWhileDead = data.useWhileDead or false,
            canCancel = data.canCancel or true,
            disable = {
                car = data.disable.car or true,
                move = data.disable.move or true,
                combat = data.disable.combat or true,
                sprint = data.disable.sprint or true
            }
        }) then
            if GetResourceState('scully_emotemenu') == 'started' then
                exports.scully_emotemenu:cancelEmote()
            else
                TriggerEvent('animations:client:EmoteCommandStart', {"c"})
            end

            return true
        end
    elseif Config.Progressbar == 'oxcircle' then
        if lib.progressCircle({
            position = 'bottom',
            duration = time,
            label = text,
            useWhileDead = data.useWhileDead or false,
            canCancel = data.canCancel or true,
            disable = {
                car = data.disable.car or true,
                move = data.disable.move or true,
                combat = data.disable.combat or true,
                sprint = data.disable.sprint or true
            }
        }) then
            if GetResourceState('scully_emotemenu') == 'started' then
                exports.scully_emotemenu:cancelEmote()
            else
                TriggerEvent('animations:client:EmoteCommandStart', {"c"})
            end

            return true
        end
    elseif Config.Progressbar == 'qb' then
        local test = false
        local cancelled = false

        Framework.Core.Functions.Progressbar("drink_something", text, time, false, true, {
            disableMovement = data.disable.move or true,
            disableCarMovement = data.disable.car or true,
            disableMouse = data.disable.mouse or true,
            disableCombat = data.disable.combat or true,
            disableInventory = true
        }, {}, {}, {}, function() -- Done
            test = true
            if GetResourceState('scully_emotemenu') == 'started' then
                exports.scully_emotemenu:cancelEmote()
            else
                TriggerEvent('animations:client:EmoteCommandStart', {"c"})
            end
        end, function()
            cancelled = true
            if GetResourceState('scully_emotemenu') == 'started' then
                exports.scully_emotemenu:cancelEmote()
            else
                TriggerEvent('animations:client:EmoteCommandStart', {"c"})
            end
        end)

        repeat
            Wait(100)
        until cancelled or test

        if test then
            return true
        end
    else
        Core.Utilities.Log({
            type = "error",
            title = "Wrong Config.Progressbar Choice",
            message = "Invalid option for Config.Progressbar. Set to any of the following: oxbar, oxcircle, qb"
        })
    end
end

-- Targetting: Add target model
---@param modelName string|number|table
---@param targetOptions table
Framework.Client.AddTargetModel = function(modelName, targetOptions)
    if Config.Target == 'qb' then
        exports['qb-target']:AddTargetModel(modelName, targetOptions)
    elseif Config.Target == 'ox' then

        for _, option in pairs(targetOptions.options) do
            option.distance = targetOptions.distance
            if option.action then
                option.onSelect = option.action
            end
        end

        exports.ox_target:addModel(modelName, targetOptions.options)
    else
        Core.Utilities.Log({
            type = "error",
            title = "Framework.Client.AddTargetModel",
            message = "Invalid value for Config.Target, must be either `qb` or `ox`"
        })
    end
end

-- Targetting: Remove target model
---@param modelName string|number|table
Framework.Client.RemoveTargetModel = function(modelName)
    if Config.Target == "qb" then
        exports['qb-target']:RemoveTargetModel(modelName)
    elseif Config.Target == 'ox' then
        exports.ox_target:removeModel(modelName)
    else
        Core.Utilities.Log({
            type = "error",
            title = "Framework.Client.RemoveTargetModel",
            message = "Invalid value for Config.Target, must be either `qb` or `ox`"
        })
    end
end

-- Targetting: Add target entity
---@param entityName string|number|table
---@param targetOptions table
Framework.Client.AddTargetEntity = function(entityName, targetOptions)
    if Config.Target == "qb" then
        exports['qb-target']:AddTargetEntity(entityName, targetOptions)
    elseif Config.Target == 'ox' then

        for _, option in pairs(targetOptions.options) do
            option.distance = targetOptions.distance
            if option.action then
                option.onSelect = option.action
            end
        end

        exports.ox_target:addLocalEntity(entityName, targetOptions.options)
    else
        Core.Utilities.Log({
            type = "error",
            title = "Framework.Client.AddTargetEntity",
            message = "Invalid value for Config.Target, must be either `qb` or `ox`"
        })
    end
end

-- Targetting: Remove target entity
---@param entityName string|number|table
Framework.Client.RemoveTargetEntity = function(entityName)
    if Config.Target == "qb" then
        exports['qb-target']:RemoveTargetEntity(entityName)
    elseif Config.Target == 'ox' then
        exports.ox_target:removeLocalEntity(entityName)
    else
        Core.Utilities.Log({
            type = "error",
            title = "Framework.Client.RemoveTargetEntity",
            message = "Invalid value for Config.Target, must be either `qb` or `ox`"
        })
    end
end

-- Targetting: Add box zone
---@param data table
Framework.Client.AddBoxZone = function(data)
    if Config.Target == "qb" then
        exports['qb-target']:AddBoxZone(data.id, data.location, data.size.length, data.size.width, {
            name = data.id,
            minZ = data.location.z - data.size.height,
            maxZ = data.location.z + data.size.height
        }, {
            options = data.options or {},
            distance = data.distance
        })
    elseif Config.Target == 'ox' then
        for _, option in pairs(data.options) do
            if option.action then
                option.onSelect = option.action
            end
        end

        exports.ox_target:addBoxZone({
            name = data.id,
            coords = data.location,
            size = vec(data.size.length, data.size.width, data.size.height),
            rotation = 0,
            debug = Config.TargetDebugging,
            options = data.options or {}
        })
    else
        Core.Utilities.Log({
            type = "error",
            title = "Framework.Client.AddBoxZone",
            message = "Invalid value for Config.Target, must be either `qb` or `ox`"
        })
    end
end
