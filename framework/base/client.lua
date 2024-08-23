Framework.Client.CurrentWeapon = false

-- Get core object
Framework.GetCoreObject = function ()
	return {}
end

-- Sends NUI a message
---@param data table
---@param updateInventory? boolean
Framework.Client.SendNUIMessage = function (data, updateInventory)
    SendNUIMessage(data)

    -- Update the inventory data
    if updateInventory then
        Core.Classes.Inventory.Update()
    end
end

-- Get player name
Framework.Client.GetPlayerName = function ()
    return GetPlayerName(source)
end

-- Get player identifier
Framework.Client.GetPlayerIdentifier = function ()
    return source
end

-- Get player cash
Framework.Client.GetPlayerCash = function ()
    return 0
end

-- Check weapon
---@param src number 
---@param weaponName string
Framework.Client.CheckWeapon = function (src, weaponName)
    
end

-- Can open inventory
Framework.Client.CanOpenInventory = function ()
    return false
end

-- Use weapon
---@param src number
---@param weaponData table
---@param shootBool boolean
Framework.Client.UseWeapon = function (src, weaponData, shootBool)
    
end

-- Has Group
---@param group table
Framework.Client.HasGroup = function(group)
    return false
end

-- Progress bar
Framework.Client.Progressbar = function (
    name, 
    label, 
    duration, 
    useWhileDead, 
    canCancel, 
    disableControls, 
    animation, 
    prop, 
    propTwo, 
    onFinish, 
    onCancel
)
    -- @todo
end

-- Targetting: Add target model
---@param modelName string|number|table
---@param targetOptions table
Framework.Client.AddTargetModel = function (modelName, targetOptions)
    if Config.Target == 'qb' then
        exports['qb-target']:AddTargetModel(modelName, targetOptions)
    elseif Config.Target == 'ox' then

        for _, option in pairs(targetOptions.options) do
            option.distance = targetOptions.distance
            if option.action then option.onSelect = option.action end
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
Framework.Client.RemoveTargetModel = function (modelName)
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
Framework.Client.AddTargetEntity = function (entityName, targetOptions)
    if Config.Target == "qb" then
        exports['qb-target']:AddTargetEntity(entityName, targetOptions)
    elseif Config.Target == 'ox' then

        for _, option in pairs(targetOptions.options) do
            option.distance = targetOptions.distance
            if option.action then option.onSelect = option.action end
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
Framework.Client.RemoveTargetEntity = function (entityName)
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
Framework.Client.AddBoxZone = function (data)
    if Config.Target == "qb" then
        exports['qb-target']:AddBoxZone(
            data.id, 
            data.location, 
            data.size.length, 
            data.size.width, 
            {
                name = data.id, 
                minZ = data.location.z - data.size.height, 
                maxZ = data.location.z + data.size.height
            }, 
            {
                options = data.options or {}, 
                distance = data.distance
            }
        )
    elseif Config.Target == 'ox' then
        for _, option in pairs(data.options) do
            if option.action then option.onSelect = option.action end
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