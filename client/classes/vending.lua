-------------------------------------------------
--- Vending Setup
-------------------------------------------------

-- Creates the vending class
Core.Classes.New("Vending", { nearVending = false, zones = {} })

-- Loads client shop locations
function Core.Classes.Vending.Load()

    if Config.UseTarget then
        Framework.Client.AddTargetModel(Config.Vending.Props, {
            options = {
                {
                    action = function ()
                        Core.Utilities.Log({
                            title = "Vending.Open()",
                            message = "Attempting to open vending"
                        })
                        
                        TriggerServerEvent(Config.ServerEventPrefix .. 'OpenVending')
                    end,
                    icon = "fas fa-eye",
                    label = Core.Language.Locale('vendingTarget')
                }
            },
            distance = Config.Vending.Radius or 1.5
        })
    else
        Core.Classes.Vending.DistanceCheck()
    end
end

-- Check if object is a vending machine
---@param model number
function Core.Classes.Vending.IsModelVendingProp (model)
    for _, prop in pairs(Config.Vending.Props) do
        if GetHashkey(prop) == model then
            return true
        end
    end

    return false
end

-- Dinstance checker for vehicles
function Core.Classes.Vending.DistanceCheck()
    CreateThread(function ()
        while true do

            local playerPos = GetEntityCoords(PlayerPedId())
            local closestObject = lib.getClosestObject(playerPos, 1.5)

            if closestObject then
                local model = GetEntityModel(closestObject)
                if Core.Classes.Vending.IsModelVendingProp(model) then
                    Core.Classes.Interact.Show(Core.Language.Locale('vendingInteractive'))
                    Core.Classes.Shops:UpdateState('nearVending', true)
                end
            else

                -- Only clear if was near vending and is now not.
                if Core.Classes.Vending:GetState('nearVending') then
                    Core.Classes.Interact.Hide()
                    Core.Classes.Shops:UpdateState('nearVending', false)
                end
            end
        
            Wait(300)
        end
    end)
end

-- Open Vending
function Core.Classes.Vending.Open()

    Core.Utilities.Log({
        title = "Vending.Open()",
        message = "Attempting to open vending"
    })

    TriggerServerEvent(Config.ServerEventPrefix .. 'OpenVending')
end

-- Cleanup
function Core.Classes.Vending.Cleanup()
    if Config.UseTarget then
        Framework.Client.RemoveTargetModel(Config.Vending.Props)
    end
end