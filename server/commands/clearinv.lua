-- Clear Inventory Command
lib.addCommand('clearinv', {
    help = 'Clears inventory of player',
    params = {{
        name = 'target',
        type = 'playerId',
        help = 'Target player\'s server id'
    }},
    restricted = Config.CommandPermissions.ClearInventory
}, function(source, args, raw)

    local Player = Framework.Server.GetPlayer(args.target)

    -- Validate that player is available
    if Player then
        Core.Classes.Inventory.ClearInventory(args.target)

        return Core.Utilities.Log({
            type = "success",
            title = "ClearInventoryCommand",
            message = "Cleared inventory for player: " .. args.target
        })
    else
        return Core.Utilities.Log({
            type = "error",
            title = "ClearInventoryCommand",
            message = "Unable to clear inventory for player: " .. args.target .. " - Player not online"
        })
    end
end)
