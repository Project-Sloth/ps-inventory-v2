-- checks for ammo boxes table and removes the item and gives ammo 
RegisterNetEvent(Config.ServerEventPrefix .. 'UseAmmoBox', function(itemRemove, itemGain)
    local Player = Framework.Server.GetPlayer(source)
    local check = Framework.Server.HasItem(source, itemRemove, 1)
    if not check then return end
    local data = {item = Config.Weapons.AmmoBoxes[itemRemove].item, amount = Config.Weapons.AmmoBoxes[itemRemove].amount}
    if data.item ~= itemGain then return end
    if Core.Classes.Inventory.RemoveItem(source, itemRemove, 1) then
        Core.Classes.Inventory.AddItem(source, data.item, data.amount)
    end
end)
