-------------------------------------------------
--- Vehicles Setup
-------------------------------------------------

-- Creates the vehicles class
Core.Classes.New("Vehicles", { nearVehicle = false })

-- Dinstance checker for vehicles
function Core.Classes.Vehicles.VehicleAccessible()
    local ped = PlayerPedId()

    if IsPedInAnyVehicle(ped, false) then
        local vehicle = GetVehiclePedIsIn(ped, false)
        local vehicleProperties = lib.getVehicleProperties(vehicle)
        Core.Classes.Vehicles:UpdateState('nearVehicle', vehicle)
        
        return {
            type = "stash",
            id = "glovebox-" .. vehicleProperties.plate,
            name = "Glovebox",
            vehicle = vehicle,
            model = vehicleProperties.model,
            class = GetVehicleClass(vehicle)
        }
    else
        local pos = GetEntityCoords(ped)
					          
        local closestVehicle = lib.getClosestVehicle(pos, 5)
        if closestVehicle == 0 or closestVehicle == nil then return false end

        local dimensionMin, dimensionMax = GetModelDimensions(GetEntityModel(closestVehicle))
		local trunkpos = GetOffsetFromEntityInWorldCoords(closestVehicle, 0.0, (dimensionMin.y), 0.0)

        if Core.Utilities.VehicleIsBackEngine(GetEntityModel(closestVehicle)) then
            trunkpos = GetOffsetFromEntityInWorldCoords(closestVehicle, 0.0, (dimensionMax.y), 0.0)
        end

        if #(pos - trunkpos) > 1.5 or IsPedInAnyVehicle(ped) then return false end
        local vehicleProperties = lib.getVehicleProperties(closestVehicle)
        Core.Classes.Vehicles:UpdateState('nearVehicle', closestVehicle)

        return {
            type = "stash",
            id = "trunk-" .. vehicleProperties.plate,
            name = "Trunk",
            vehicle = closestVehicle,
            model = vehicleProperties.model,
            class = GetVehicleClass(closestVehicle)
        }
    end

    return false
end

-- Dinstance checker for vehicles
function Core.Classes.Vehicles.DistanceCheck()
    if Core.Classes.Inventory:GetState('IsOpen') and Core.Classes.Inventory:GetState('External') ~= false and Core.Classes.Vehicles:GetState('nearVehicle') then
        local external = Core.Classes.Inventory:GetState('External')
        local nearVehicle = Core.Classes.Vehicles:GetState('nearVehicle')

        if type(external) == "table" then
            if external.id then
                if external.id:find('trunk-') then
                    local checkVehicle = Core.Classes.Vehicles.VehicleAccessible()

                    if checkVehicle == false then
                        Core.Classes.Inventory.Close()
                    end

                    if type(checkVehicle) == "table" and checkVehicle.vehicle ~= nearVehicle then
                        Core.Classes.Inventory.Close()
                    end
                end
            end
        end
    end

    Wait(300)
end