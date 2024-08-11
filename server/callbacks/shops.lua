-------------------------------------------------
--- Buy item from a shop
-------------------------------------------------
lib.callback.register(Config.ServerEventPrefix .. "Buy", function (source, data)

    -- Validate player
    local src = source
    local Player = Framework.Server.GetPlayer(src)
    if not data.shop then return { success = false } end

    -- Validate shop
    local shop = Config.Shops[data.shop.id]
    if not shop then return { success = false } end
    local items = Core.Classes.Shops.BuildItemList(shop.items)

    -- Verify the item by name and slot
    -- @todo switch to Core.Classes.Inventory.Utilities.GetItemFromListByName()
    local itemVerified = false
    for k, item in pairs(items) do
        if item.name == data.itemData.item.name and tonumber(item.slot) == tonumber(data.itemData.slot) then
            itemVerified = item
        end
    end

    -- If item was verified
    if not itemVerified then return { success = false } end

    -- Calculate price
    if tonumber(data.amount) < 1 then return { success = false } end
    local price = tonumber(itemVerified.price) * tonumber(data.amount)

    -- Validate player cash
    local playerCash = Framework.Server.GetPlayerCash(src)
    if not playerCash then return { success = false } end
    if playerCash < price then return { success = false, message = "You do not have enough cash." } end

    -- Charge player
    local charged = Framework.Server.ChargePlayer(src, "cash", price, "Store purchase")
    if not charged then return { success = false, message = "Unable to charge, please try again."} end

    -- Add item and send response
    Core.Classes.Inventory.AddItem(src, itemVerified.name, data.amount)
    TriggerClientEvent(Config.ClientEventPrefix .. "Update", src, { items = Core.Classes.Inventory.GetPlayerInventory(src) })
    return { success = true }
end)