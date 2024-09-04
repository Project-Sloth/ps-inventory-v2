Core.Classes.New("Shops")

-- Builds item list from shop item list
---@param items table
function Core.Classes.Shops.BuildItemList(items)
    local itemList = {}

    for slotId, item in pairs(items) do
        local itemData = Core.Classes.Inventory:GetState("Items")[item.item]
        if itemData then
            itemData.price = item.price
            itemData.slot = slotId
            itemData.amount = 1

            if item.job then itemData.job = item.job end
            if item.license then itemData.license = item.license end
            if item.info then
                if not itemData.info then itemData.info = {} end

                for k, v in pairs(item.info) do
                    itemData.info[k] = v
                end
            end

            table.insert(itemList, itemData)
        end
    end

    return itemList
end

-- Buy Item
---@param source number
---@param data table
function Core.Classes.Shops.BuyItem (source, data)
    -- Validate player
    local src = source
    local player = Framework.Server.GetPlayer(src)

    if not data.shop then 
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Shops.BuyItem",
            message = "No shop data was passed"
        })

        return { success = false } 
    end

    local items = {}
    -- If shop id is vending, skip shop validation
    if data.shop.id == 'vending' then
        items = Core.Classes.Shops.BuildItemList(Config.Vending.Items)
    else
        -- Validate shop
        local shop = Config.Shops[data.shop.id]
        if shop then  
            items = Core.Classes.Shops.BuildItemList(shop.items)
        else
            items = Core.Classes.Shops.BuildItemList(data.itemData)
        end
    end

    -- @todo return early
    if Config.Framework == "qb" and Config.OldCore then
        if player.Functions.RemoveMoney('cash', data.itemData.item.price * data.amount) or player.Functions.RemoveMoney('bank', data.itemData.item.price * data.amount)  then 
            player.Functions.AddItem(data.itemData.item.name, data.amount)
            return
        else
            Core.Classes.Inventory.Utilities.Notify(player, 'You don\'t have enough Money.', 'error')
            return
        end
    end

    -- Verify the item by name and slot
    -- @todo switch to Core.Classes.Inventory.Utilities.GetItemFromListByName()
    local itemVerified = false
    for k, item in pairs(items) do
        if item.name == data.itemData.item.name and tonumber(item.slot) == tonumber(data.itemData.slot) then
            itemVerified = item
        end
    end
    
    -- If item was verified
    if not itemVerified then 
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Shops.BuyItem",
            message = "Unable to verify item"
        })

        return { success = false } 
    end

    -- If it requires a license
    if itemVerified.license then
        local hasLicense = Framework.Server.HasLicense(source, itemVerified.license)
        if not hasLicense then return { success = false, message = ("You do not have a %s license"):format(itemVerified.license)} end
    end

    -- Calculate price
    if tonumber(data.amount) < 1 then 
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Shops.BuyItem",
            message = "Incorrect amount passed for item"
        })

        return { success = false } 
    end

    local price = tonumber(itemVerified.price) * tonumber(data.amount)

    -- Weight check
    if not Core.Classes.Inventory.CanCarryItem(src, itemVerified.name, data.amount) then
        return { success = false, message = "You do not have enough weight" }
    end

    -- Validate player cash
    local playerCash, playerBank = Framework.Server.GetPlayerMoney(src)
    
    if not playerCash or not playerBank then return { success = false } end
    if playerCash < price then
        if playerBank < price then 
            return { success = false, message = "You do not have enough Money." } 
        end
    end
    -- Charge player
    local charged = Framework.Server.ChargePlayer(src, "cash", price, "Store purchase")
    if not charged then 
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Shops.BuyItem",
            message = "Unable to charge player"
        })

        return { success = false, message = "Unable to charge, please try again."} 
    end

    -- Info check
    local info = {}
    if itemVerified.info then info = itemVerified.info end

    -- Add item and send response
    Core.Classes.Inventory.AddItem(src, itemVerified.name, data.amount, nil, info)
    TriggerClientEvent(Config.ClientEventPrefix .. "Update", src, { items = Core.Classes.Inventory.GetPlayerInventory(src) })
    
    return { success = true }
end


-- Open Shop
---@param src number
---@param shopId string
function Core.Classes.Shops.Open (src, shopId, name)
    local player = Framework.Server.GetPlayer(src)
    local shop = Config.Shops[shopId]

    -- Handle vending
    if shopId == 'vending' then
        local items = Core.Classes.Shops.BuildItemList(Config.Vending.Items)

        return Core.Classes.Inventory.OpenInventory(src, {
            type = "shop",
            id = 'vending',
            name = 'Vending Machine',
            slots = #items,
            items = items
        })
    end

    if not shop then
        if not name then 
           
            return Core.Utilities.Log({
                type = "error",
                title = "OpenShop",
                message = "Shop[" .. shopId .. "] does not exist"
            })
        else
            local items = Core.Classes.Shops.BuildItemList(name.items)
            return Core.Classes.Inventory.OpenInventory(src, {
                type = "shop",
                id = shopId,
                name = name.label,
                slots = name.slots,
                items = items
            })
        end
    end

    local items = Core.Classes.Shops.BuildItemList(shop.items)

    Core.Classes.Inventory.OpenInventory(src, {
        type = "shop",
        id = shopId,
        name = shop.name,
        slots = #shop.items,
        items = items
    })
end

exports("OpenShop", Core.Classes.Shops.Open)
exports("OpenVending", function ()
    Core.Classes.Shops.Open(source, 'vending')
end)
