-------------------------------------------------
--- Payload for nui init
-------------------------------------------------
function InventoryInitPayload ()
    return {
        action = "init",
        debugging = Config.Debugging,
        player = {
            name = Framework.Client.GetPlayerName(),
            identifier = Framework.Client.GetPlayerIdentifier(),
            cash = Framework.Client.GetPlayerCash()
        },
        inventory = {
            MaxInventoryWeight = Config.Inventories.Player.MaxWeight,
            MaxInventorySlots = Config.Inventories.Player.MaxSlots
        }
    }
end

-------------------------------------------------
--- Starts threads for classes
-------------------------------------------------
function CreateInventoryThreads ()

    -------------------------------------------------
    --- Health updates
    -------------------------------------------------
    Core.Classes.Player.Reset()
    CreateThread(function ()
        while true do
            Core.Classes.Player.UpdateHealth(true)
            Wait(2000)
        end
    end)

    
    -------------------------------------------------
    --- Class loads
    -------------------------------------------------
    CreateThread(function ()
        Core.Classes.Crafting.Load()

        if Config.Placeables.Enabled then
            Core.Classes.Placeables.Load()
        end

        Core.Classes.Stashes.Load()
        Core.Classes.Shops.Load()
        Core.Classes.Vending.Load()
    end)

    -------------------------------------------------
    --- Key presses
    -------------------------------------------------
    if not Config.UseTarget and Config.Interact then
        CreateThread(function ()
            while true do

                -- Pickup placeable item
                if IsControlJustPressed(0, 38) and IsControlPressed(0, 21) then
                    Core.Classes.Placeables.Pickup()
                -- General interactive key
                elseif IsControlJustPressed(0, Config.InteractKey.Code) then
                    Core.Classes.Crafting.Open()

                    if Config.Placeables.Enabled then
                        Core.Classes.Placeables.Open()
                    end

                    Core.Classes.Stashes.Open()
                    Core.Classes.Shops.Open()
                end

                Wait(0)
            end
        end)
    end

    -------------------------------------------------
    --- Vehicle checking thread
    -------------------------------------------------
    CreateThread(function ()
        while true do
            Core.Classes.Vehicles.DistanceCheck()
        end
    end)
end