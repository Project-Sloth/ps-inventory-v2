-------------------------------------------------
--- Inventory command
-------------------------------------------------
lib.addCommand('inventory', {
    help = 'Open inventory',
    params = {}
}, function(source, args, raw)
    TriggerClientEvent(Config.ClientEventPrefix .. "OpenInventory", source)
end)