-- Inventory command
lib.addCommand('inventory', {
    help = 'Open inventory',
    params = {}
}, function(source, args, raw)
    TriggerClientEvent(Config.ClientEventPrefix .. "OpenInventory", source)
end)

-- Open a player's inventory
lib.addCommand('playerinv', {
    help = 'See player inventory',
    params = {{
        name = 'target',
        type = 'playerId',
        help = 'Target player\'s server id'
    }},
    restricted = Config.CommandPermissions.PlayerInventory
}, function(source, args, raw)
    Core.Classes.Inventory.OpenInventoryById(source, args.target)
end)