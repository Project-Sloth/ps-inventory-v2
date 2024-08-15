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