-- Slot commands
for i = 1, 5 do
    lib.addCommand('slot' .. i, {
        help = 'Uses item in slot ' .. i,
    }, function(source, args, raw)
        TriggerEvent(Config.ServerEventPrefix .. 'UseItemSlot', i)
    end)
end
