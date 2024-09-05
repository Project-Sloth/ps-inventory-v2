-- checks for ammo boxes table and removes the item and gives ammo 
RegisterNetEvent(Config.ServerEventPrefix .. 'UseAmmoBox', function(itemremove, itemgain)
    local Player = Framework.Server.GetPlayer(source)
    local check = Framework.Server.HasItem(source, itemremove, 1)
    if not check then return end
    local data = {item = Config.Weapons.AmmoBoxes[itemremove].item, amount = Config.Weapons.AmmoBoxes[itemremove].amount}
    if data.item ~= itemgain then return end
    if Core.Classes.Inventory.RemoveItem(source, itemremove, 1) then
        Core.Classes.Inventory.AddItem(source, data.item, data.amount)
    end
end)
