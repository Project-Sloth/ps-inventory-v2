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
    --- Class loads
    -------------------------------------------------
    CreateThread(function ()
        if not Core.Classes.Inventory:GetState('Loaded') then Wait(1000) end
        Core.Classes.Crafting.Load()
        Core.Classes.Placeables.Load()
        Core.Classes.Stashes.Load()
        Core.Classes.Shops.Load()
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
                end

                -- General interactive key
                if IsControlJustPressed(0, Config.InteractKey.Code) then
                    Core.Classes.Crafting.Open()
                    Core.Classes.Placeables.Open()
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
            if not Core.Classes.Inventory:GetState('Loaded') then Wait(1000) end
            Core.Classes.Vehicles.DistanceCheck()
        end
    end)
end