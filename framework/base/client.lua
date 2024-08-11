Framework.Client.CurrentWeapon = false

-------------------------------------------------
--- GETS CORE OBJECT
-------------------------------------------------
Framework.GetCoreObject = function ()
	return {}
end

-------------------------------------------------
--- GET PLAYER NAME
-------------------------------------------------
Framework.Client.GetPlayerName = function ()
    return GetPlayerName(source)
end

-------------------------------------------------
--- GET PLAYER IDENTIFIER
-------------------------------------------------
Framework.Client.GetPlayerIdentifier = function ()
    return source
end

-------------------------------------------------
--- GET PLAYER CASH
-------------------------------------------------
Framework.Client.GetPlayerCash = function ()
    return 0
end

-------------------------------------------------
--- CHECK WEAPON
-------------------------------------------------
Framework.Client.CheckWeapon = function (src, weaponName)
    
end

-------------------------------------------------
--- CHECK WEAPON
-------------------------------------------------
Framework.Client.CanOpenInventory = function ()
    return false
end

-------------------------------------------------
--- USE WEAPON
-------------------------------------------------
Framework.Client.UseWeapon = function (src, weaponData, shootBool)
    
end

-------------------------------------------------
--- Has Group
-------------------------------------------------
Framework.Client.HasGroup = function(group)
    return false
end

-------------------------------------------------
--- Progress bar
-------------------------------------------------
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

-------------------------------------------------
--- Targetting: Add target model
-------------------------------------------------
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

-------------------------------------------------
--- Targetting: Remove target model
-------------------------------------------------
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

-------------------------------------------------
--- Targetting: Add target entity
-------------------------------------------------
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

-------------------------------------------------
--- Targetting: Remove target entity
-------------------------------------------------
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

-------------------------------------------------
--- Targetting: Add box zone
-------------------------------------------------
-- {
--     id = "id",
--     location = vector3(0, 0, 0),
--     size = { length = 1, width = 1, height = 2 },
--     options = { }
-- }
-------------------------------------------------
Framework.Client.AddBoxZone = function (data)
    if Config.Target == "qb" then
        exports['qb-target']:AddBoxZone(
            data.id, 
            data.location, 
            data.size.length, 
            data.size.width, 
            {
                name = data.location, 
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