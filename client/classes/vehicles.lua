-------------------------------------------------
--- Vehicles Setup
-------------------------------------------------

-- Creates the vehicles class
Classes.New("Vehicles", { nearVehicle = false })

-------------------------------------------------
--- Dinstance checker for vehicles
-------------------------------------------------
function Classes.Vehicles.VehicleAccessible()
    local ped = PlayerPedId()

    if IsPedInAnyVehicle(ped, false) then
        local vehicle = GetVehiclePedIsIn(ped, false)
        local vehicleProperties = lib.getVehicleProperties(vehicle)
        Classes.Vehicles:UpdateState('nearVehicle', vehicle)
        return {
            type = "stash",
            id = "glovebox-" .. vehicleProperties.plate,
            name = "Glovebox",
            vehicle = vehicle
        }
    else
        local pos = GetEntityCoords(ped)
					          
        local closestVehicle = lib.getClosestVehicle(pos, 5)

        if closestVehicle == 0 or closestVehicle == nil then 
            return false 
        end

        local dimensionMin, dimensionMax = GetModelDimensions(GetEntityModel(closestVehicle))
		local trunkpos = GetOffsetFromEntityInWorldCoords(closestVehicle, 0.0, (dimensionMin.y), 0.0)

        if (Config.Vehicles.BackEngineVehicles[GetEntityModel(closestVehicle)]) then
            trunkpos = GetOffsetFromEntityInWorldCoords(closestVehicle, 0.0, (dimensionMax.y), 0.0)
        end

        if #(pos - trunkpos) > 1.5 or IsPedInAnyVehicle(ped) then
            return false
        end

        local vehicleProperties = lib.getVehicleProperties(closestVehicle)

        Classes.Vehicles:UpdateState('nearVehicle', closestVehicle)

        return {
            type = "stash",
            id = "trunk-" .. vehicleProperties.plate,
            name = "Trunk",
            vehicle = closestVehicle
        }
    end

    return false
end

-------------------------------------------------
--- Dinstance checker for vehicles
-------------------------------------------------
function Classes.Vehicles.DistanceCheck()
    if Classes.Inventory:GetState('IsOpen') and Classes.Inventory:GetState('External') ~= false and Classes.Vehicles:GetState('nearVehicle') then
        local external = Classes.Inventory:GetState('External')
        local nearVehicle = Classes.Vehicles:GetState('nearVehicle')

        if type(external) == "table" then
            if external.id then
                if external.id:find('trunk-') then
                    local checkVehicle = Classes.Vehicles.VehicleAccessible()

                    if checkVehicle == false then
                        Classes.Inventory.Close()
                    end

                    if type(checkVehicle) == "table" and checkVehicle.vehicle ~= nearVehicle then
                        Classes.Inventory.Close()
                    end
                end
            end
        end
    end

    Wait(300)
end