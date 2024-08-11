-------------------------------------------------
--- Inventory Setup (Runs when server starts)
-------------------------------------------------
-- Creates the inventory class
Core.Classes.New("Inventory", {

    -- Holds items
    Items = {},

    -- Caching player inventories until save
    Inventories = {}
})

-------------------------------------------------
--- Inventory utility methods
-------------------------------------------------
Core.Classes.Inventory.Utilities = {

    -- Get the slot key of an item's slot number
    GetSlotKeyForItemBySlotNumber = function (items, slot)
        if not slot then return nil end
        slot = tonumber(slot)
        local res = nil

        for key, item in pairs(items) do
            if tonumber(item.slot) == slot then
                res = key
            end
        end

        return res
    end,

    -- Get a specific item from a list
    GetItemFromListByName = function (items, itemName, slot)

        if slot then slot = tonumber(slot) end
        local res = nil

        for _, item in pairs(items) do
            if slot then
                if item.name == itemName and tonumber(item.slot) == slot then
                    res = item
                end
            else
                if item.name == itemName then
                    res = item
                end
            end
        end

        return res
    end,

    -- Removes an item from a list by it's slot 
    RemoveItemFromListBySlot = function (slot, items)
        for k, item in pairs(items) do
            if item.slot == slot then
                table.remove(items, k)
            end
        end

        return items
    end,

    -- Adds an item to the list
    AddItemToList = function (items, item, slot)
        if slot then item.slot = slot end
        table.insert(items, item)
        return items
    end,

    -- Converts item to expected format
    ConvertItem = function (item, additionalInfo)

        -- Get original data
        local itemInfo = Core.Classes.Inventory:GetState("Items")[item.name]
        if not itemInfo then
            return nil
        end

        -- The conversation table.
        local itemConverted = {
            name = itemInfo.name,
            amount = item.amount,
            info = item.info or {},
            label = itemInfo.label,
            description = itemInfo.description or '',
            weight = itemInfo.weight,
            type = itemInfo.type,
            unique = itemInfo.unique,
            useable = itemInfo.useable,
            image = itemInfo.image,
            shouldClose = itemInfo.shouldClose,
            slot = item.slot,
            combinable = itemInfo.combinable,
            created = item.created or os.time()
        }

        -- If additional data provided, merge it
        if additionalInfo then
            if type(additionalInfo) == "table" then
                for k, v in pairs(additionalInfo) do
                    itemConverted[k] = v
                end
            end
        end

        return itemConverted
    end
}

-------------------------------------------------
--- Load Inventory Items
-------------------------------------------------
function Core.Classes.Inventory.Load(init)
    Core.Classes.Inventory:UpdateState('Items', Framework.Server.GetInventoryItems(), function(items)
        Core.Utilities.Log({
            title = "Inventory Loaded",
            message = Core.Utilities.TableLength(items) .. " were loaded for inventory use"
        })
        
        if init then
            for item, func in pairs(Config.Useables) do
                Core.Classes.Inventory.CreateUseableItem(item, func)
            end

            -- Create useables for placeable items from crafting
            for item, data in pairs(Config.Crafting.Placeables) do
                Core.Classes.Inventory.CreateUseableItem(item, function (source, itemData)
                    itemData.placeableType = 'crafting'
                    itemData.recipes = data.recipes
                    itemData.prop = data.prop
                    itemData.eventType = "server"
                    itemData.eventName = Config.ServerEventPrefix .. 'OpenCraftingByPlaceable'
                    itemData.interactType = "crafting"
                    itemData.eventParams = { id = item }
                    TriggerClientEvent(Config.ClientEventPrefix .. 'PlaceItem', source, itemData)
                end)
            end
        end
    end)
end

-------------------------------------------------
--- Sync player inventors to database
-------------------------------------------------
function Core.Classes.Inventory.SyncDatabase()
    local players = Framework.Server.GetPlayers()
    local saved = 0

    for _, source in pairs(players) do

        -- Will sync to database
        local res = Framework.Server.SavePlayerInventory(source, false, true)

        if not res then 
            Core.Utilities.Log({
                type = "error",
                title = "Inventory.SyncDatabase",
                message = "Unable to sync inventory for " .. Framework.Server.GetPlayerName(source)
            })
        else
            Core.Utilities.Log({
                title = "Inventory.SyncDatabase",
                message = "Synced inventory for " .. Framework.Server.GetPlayerName(source)
            })

            saved = saved + 1
        end
    end

    Core.Utilities.Log({
        title = "Inventory.SyncDatabase",
        message = "Synced " .. saved .. " / " .. Core.Utilities.TableLength(players) .. " player inventories to database"
    })
end

-------------------------------------------------
--- Validate Items
-------------------------------------------------
function Core.Classes.Inventory.ValidateItems(items)
    local inventory = {}

    -- If not a table, log and return empty
    if type(items) ~= "table" then

        Core.Utilities.Log({
            type = "error",
            title = "Item Validation",
            message = "Requires items parameter to be of type table."
        })

        return inventory
    end

    -- If table is empty, return early
    if table.type(items) == "empty" then
        return inventory
    end

    -- Iterate through items and setup inventory to return
    for _, item in pairs(items) do
        if item then

            local itemConverted = Core.Classes.Inventory.Utilities.ConvertItem(item)

            if itemConverted then
                table.insert(inventory, itemConverted)
            end
        end
    end

    return inventory
end

-------------------------------------------------
--- Retrieve all available inventory items
--- Export: exports['ir8-inventory']:Items()
-------------------------------------------------
function Core.Classes.Inventory.Items()
    return Core.Classes.Inventory:GetState('Items')
end

exports("Items", Core.Classes.Inventory.Items)

-------------------------------------------------
--- Check if item exists
--- Export: exports['ir8-inventory']:ItemExists(item)
-------------------------------------------------
function Core.Classes.Inventory.ItemExists(item)
    if not Core.Classes.Inventory:GetState('Items')[item] then
        return false
    end

    return true
end

exports("ItemExists", Core.Classes.Inventory.ItemExists)

-------------------------------------------------
--- Get player inventory
--- Export: exports['ir8-inventory']:GetPlayerInventory(src)
-------------------------------------------------
function Core.Classes.Inventory.GetPlayerInventory(src)

    local inventory = Framework.Server.GetPlayerInventory(src)
    if not inventory then
        return {}
    end

    -- Validate and return inventory
    inventory = Core.Classes.Inventory.ValidateItems(inventory)

    -- Return the inventory items
    return inventory
end

exports("GetPlayerInventory", Core.Classes.Inventory.GetPlayerInventory)

-------------------------------------------------
--- Saves player inventory
--- Export: exports['ir8-inventory']:SavePlayerInventory(src, offline)
-------------------------------------------------
function Core.Classes.Inventory.SavePlayerInventory(src, inventory)

    if inventory == nil then
        inventory = Framework.Server.GetPlayerInventory(src)
    end

    -- Validate and return inventory
    inventory = Core.Classes.Inventory.ValidateItems(inventory)

    -- Save player inventory
    return Framework.Server.SavePlayerInventory(src, inventory)
end

exports("SaveInventory", Core.Classes.Inventory.SaveInventory)
exports("SavePlayerInventory", Core.Classes.Inventory.SaveInventory)

-------------------------------------------------
--- Calculate weight of inventory
--- Server Event: ir8-inventory:Server:GetTotalWeight
--- Export: exports['ir8-inventory']:GetTotalWeight(items)
-------------------------------------------------
function Core.Classes.Inventory.GetTotalWeight(items)
    local weight = 0
    if not items then
        return 0
    end
    for _, item in pairs(items) do
        if item then
            weight = weight + (item.weight * (item.amount or 1))
        end
    end
    return tonumber(weight)
end

exports("GetTotalWeight", Core.Classes.Inventory.GetTotalWeight)

-------------------------------------------------
--- See if player has item (or amount of)
--- Server Event: ir8-inventory:Server:HasItem
--- Export: exports['ir8-inventory']:HasItem(items)
-------------------------------------------------
function Core.Classes.Inventory.HasItem(source, items, count)
    return Framework.Server.HasItem(source, items, count)
end

exports("HasItem", Core.Classes.Inventory.HasItem)

-------------------------------------------------
--- Get slot of inventory and return the item
--- Server Event: ir8-inventory:Server:GetSlot
--- Export: exports['ir8-inventory']:GetSlot(src, slot)
-------------------------------------------------
function Core.Classes.Inventory.GetSlot(src, slot)
    local Inventory = Core.Classes.Inventory.GetPlayerInventory(src)
    slot = tonumber(slot)
    local slotKey = false

    for k, item in pairs(Inventory) do
        if tonumber(item.slot) == tonumber(slot) then
            slotKey = k
        end
    end

    if not slotKey then
        return false
    end

    return Inventory[slotKey]
end

exports("GetSlot", Core.Classes.Inventory.GetSlot)

-------------------------------------------------
--- Get player slot number with item
--- Server Event: ir8-inventory:Server:GetSlotNumberWithItem
--- Export: exports['ir8-inventory']:GetSlotNumberWithItem(src, item)
-------------------------------------------------
function Core.Classes.Inventory.GetSlotNumberWithItem(src, itemName)
    local Inventory = Core.Classes.Inventory.GetPlayerInventory(src)

    for slot, item in pairs(Inventory) do
        if item.name:lower() == itemName:lower() then
            return tonumber(slot)
        end
    end

    return nil
end

exports("GetSlotNumberWithItem", Core.Classes.Inventory.GetSlotNumberWithItem)

-------------------------------------------------
--- Get player slot with item
--- Server Event: ir8-inventory:Server:GetSlotWithItem
--- Export: exports['ir8-inventory']:GetSlotWithItem(src, item)
-------------------------------------------------
function Core.Classes.Inventory.GetSlotWithItem(src, itemName, items)
    local Inventory = items and items or Core.Classes.Inventory.GetPlayerInventory(src)

    for slot, item in pairs(Inventory) do
        if item.name:lower() == itemName:lower() then
            return item
        end
    end

    return nil
end

exports("GetSlotWithItem", Core.Classes.Inventory.GetSlotWithItem)

-------------------------------------------------
--- Get player slots with item
--- Server Event: ir8-inventory:Server:GetSlotsWithItem
--- Export: exports['ir8-inventory']:GetSlotsWithItem(src, item)
-------------------------------------------------
function Core.Classes.Inventory.GetSlotsWithItem(src, itemName)
    local Inventory = Core.Classes.Inventory.GetPlayerInventory(src)
    local slots = {}

    for slot, item in pairs(Inventory) do
        if item.name:lower() == itemName:lower() then
            table.insert(slots, slot)
        end
    end

    return slots
end

exports("GetSlotsWithItem", Core.Classes.Inventory.GetSlotsWithItem)

-------------------------------------------------
--- Open player inventory
--- Server Event: ir8-inventory:Server:OpenInventory
--- Export: exports['ir8-inventory']:OpenInventory(src)
-------------------------------------------------
function Core.Classes.Inventory.OpenInventory(src, external)
    TriggerClientEvent(Config.ClientEventPrefix .. 'OpenInventory', src, external)
end

exports("OpenInventory", Core.Classes.Inventory.OpenInventory)

-------------------------------------------------
--- Open target player inventory
--- Server Event: ir8-inventory:Server:OpenInventoryById
--- Export: exports['ir8-inventory']:OpenInventoryById(src, target)
-------------------------------------------------
function Core.Classes.Inventory.OpenInventoryById(src, target)
    if src == target then return false end

    local Player = Framework.Server.GetPlayer(src)
    if not Player then return false end

    local Target = Framework.Server.GetPlayer(target)
    if not Target then return false end

    Core.Classes.Inventory.CloseInventory(target)

    if not Player(target).state.inventoryBusy then
        Player(target).state.inventoryBusy = true
    end

    local items = Core.Classes.Inventory.LoadExternalInventory('player', target)
    return Core.Classes.Inventory.OpenInventory(src, {
        type = "player",
        id = target,
        name = Framework.Server.GetPlayerName(src),
        slots = #items,
        items = items
    })
end

exports("OpenInventoryById", Core.Classes.Inventory.OpenInventoryById)

-------------------------------------------------
--- Close player inventory
--- Server Event: ir8-inventory:Server:CloseInventory
--- Export: exports['ir8-inventory']:CloseInventory(src)
-------------------------------------------------
function Core.Classes.Inventory.CloseInventory(src)
    TriggerClientEvent(Config.ClientEventPrefix .. 'CloseInventory', src)
end

exports("CloseInventory", Core.Classes.Inventory.CloseInventory)

-------------------------------------------------
--- Creats a useable item
--- Server Event: ir8-inventory:Server:CreateUseableItem
--- Export: exports['ir8-inventory']:CreateUseableItem(itemName, data)
-------------------------------------------------
function Core.Classes.Inventory.CreateUseableItem(itemName, data)
	Framework.Server.CreateUseableItem(itemName, data)
end

exports("CreateUseableItem", Core.Classes.Inventory.CreateUseableItem)

-------------------------------------------------
--- Validates item then uses it
--- Server Event: ir8-inventory:Server:ValidateAndUseItem
--- Export: exports['ir8-inventory']:ValidateAndUseItem(src, itemData)
-------------------------------------------------
function Core.Classes.Inventory.ValidateAndUseItem(src, itemData)
    if itemData then
        local itemInfo = Core.Classes.Inventory:GetState("Items")[itemData.name]

        -- Handle weapon types
        if itemData.type == "weapon" then

            -- Validate quality
            if itemData.info.quality then
                if itemData.info.quality > 0 then
                    TriggerClientEvent(Config.ClientEventPrefix .. "UseWeapon", src, itemData, true)
                else
                    TriggerClientEvent(Config.ClientEventPrefix .. "UseWeapon", src, itemData, false)
                end
            else
                TriggerClientEvent(Config.ClientEventPrefix .. "UseWeapon", src, itemData, true)
            end

            -- Handle useable items
        elseif itemData.useable then

            -- Validate quality
            if itemData.info.quality then
                if itemData.info.quality > 0 then
                    Core.Classes.Inventory.UseItem(itemData.name, src, itemData)
                end
            else
                Core.Classes.Inventory.UseItem(itemData.name, src, itemData)
            end
        end
    end
end

exports("ValidateAndUseItem", Core.Classes.Inventory.ValidateAndUseItem)

-------------------------------------------------
--- Uses an item if applicable
--- Server Event: ir8-inventory:Server:UseItem
--- Export: exports['ir8-inventory']:UseItem(item)
-------------------------------------------------
function Core.Classes.Inventory.UseItem(item, ...)
    Core.Utilities.Log({
        title = "UseItem",
        message = "Attempting to use item"
    })

    local itemData = Framework.Server.GetUseableItem(item)
    local callback = type(itemData) == 'table' and
                         (rawget(itemData, '__cfx_functionReference') and itemData or itemData.cb or itemData.callback) or
                         type(itemData) == 'function' and itemData
    if not callback then
        return Core.Utilities.Log({
            type = "error",
            title = "UseItem",
            message = "Unable to use item, no callback found."
        })
    end

    callback(...)
end

exports("UseItem", Core.Classes.Inventory.UseItem)

-------------------------------------------------
--- Adds an item to the inventory
--- Server Event: ir8-inventory:Server:AddItem
--- Export: exports['ir8-inventory']:AddItem
-------------------------------------------------
function Core.Classes.Inventory.AddItem(source, item, amount, slot, info, reason, created)

    -- Player information
    local Player = Framework.Server.GetPlayer(source)
    if not Player then
        return false
    end

    local items = Core.Classes.Inventory.GetPlayerInventory(source)

    -- Get the total weight of the inventory
    local totalWeight = Core.Classes.Inventory.GetTotalWeight(items)

    -- Get the item information
    local itemInfo = Core.Classes.Inventory:GetState('Items')[item:lower()]

    -- If the item does not exist, or the
    if not itemInfo then return false end

    -- Get the current time
    local time = os.time()

    -- Set the quanity
    amount = tonumber(amount) or 1

    -- Set the slot number, or if it exists get that slot number
    slot = tonumber(slot) or Core.Classes.Inventory.GetSlotNumberWithItem(source, item)

    -- Make sure info is a table
    info = type(info) == "table" and info or {} -- Make sure it's not an empty string and is a table

    -- Set the created time of the info if not provided
    itemInfo.created = created or time

    -- Set quality of the item
    info.quality = info.quality or 100

    -- If is a weapon, set the serial number and quality
    if itemInfo.type == 'weapon' then
        info.serie = info.serie or nil
        info.quality = info.quality or 100
    end

    -- Check the weight with the new item
    if (totalWeight + (itemInfo.weight * amount)) <= Config.Player.MaxInventoryWeight then

        -- If stackable
        if (slot and items[slot]) and (items[slot].name:lower() == item:lower()) and
            (itemInfo.type == 'item' and not itemInfo.unique) then

            -- Quality must match before stacking
            if items[slot].info.quality == info.quality then

                items[slot].amount = items[slot].amount + amount
                TriggerClientEvent(Config.ClientEventPrefix .. 'InventoryNotify', source, 'add', itemInfo, amount)
                Framework.Server.SavePlayerInventory(source, items)
                if Player.Offline then return true end
                return true

                -- If quality does not match, add to a new slot
            else
                for i = 1, Config.Player.MaxInventorySlots, 1 do
                    if items[i] == nil then
                        items[i] = Core.Classes.Inventory.Utilities.ConvertItem(itemInfo, {
                            slot = i,
                            info = info or {},
                            amount = amount
                        })

                        TriggerClientEvent(Config.ClientEventPrefix .. 'InventoryNotify', source, 'add', itemInfo, amount)
                        Framework.Server.SavePlayerInventory(source, items)
                        if Player.Offline then return true end
                        return true
                    end
                end
            end

            -- If stackable
        elseif not itemInfo.unique and slot or slot and items[slot] == nil then
            items[slot] = Core.Classes.Inventory.Utilities.ConvertItem(itemInfo, {
                slot = slot,
                info = info or {},
                amount = amount
            })

            TriggerClientEvent(Config.ClientEventPrefix .. 'InventoryNotify', source, 'add', itemInfo, amount)
            Framework.Server.SavePlayerInventory(source, items)
            if Player.Offline then return true end
            return true

            -- If not stackable
        elseif itemInfo.unique or (not slot or slot == nil) or itemInfo.type == 'weapon' then
            for i = 1, Config.Player.MaxInventorySlots, 1 do
                if items[i] == nil then
                    items[i] = Core.Classes.Inventory.Utilities.ConvertItem(itemInfo, {
                        slot = i,
                        info = info or {},
                        amount = amount
                    })

                    TriggerClientEvent(Config.ClientEventPrefix .. 'InventoryNotify', source, 'add', itemInfo, amount)
                    Framework.Server.SavePlayerInventory(source, items)
                    if Player.Offline then return true end
                    return true
                end
            end
        end
    elseif not Player.Offline then
        -- @TODO Notify of too full
    end
    return false
end

exports("AddItem", Core.Classes.Inventory.AddItem)

-------------------------------------------------
--- Remove an item from inventory
--- Server Event: ir8-inventory:Server:RemoveItem
--- Export: exports['ir8-inventory']:RemoveItem
-------------------------------------------------
function Core.Classes.Inventory.RemoveItem(source, item, amount, slot)

    -- Validate player
    local Player = Framework.Server.GetPlayer(source)
    if not Player then return false end

    -- Get player inventory
    local items = Core.Classes.Inventory.GetPlayerInventory(source)

    -- Validate item
    local itemData = Core.Classes.Inventory:GetState("Items")[item:lower()]
    if not itemData then return end

    amount = tonumber(amount) or 1

    -- If the slot number is provided
    if slot then

        -- Look for the slot key based on slot id
        local slotKey = false
        if slot then 
            for k, i in pairs(items) do
                if (tonumber(i.slot) == tonumber(slot)) then slotKey = k end
            end
        end

        if slotKey then

            -- If they have more than what is being removed
            if items[slotKey].amount > amount then
                items[slotKey].amount = items[slotKey].amount - amount
                Framework.Server.SavePlayerInventory(source, items)
                TriggerClientEvent(Config.ClientEventPrefix .. 'InventoryNotify', source, 'remove', itemData, amount)
                return true

                -- If the amount matches
            elseif items[slotKey].amount == amount then
                items[slotKey] = nil
                Framework.Server.SavePlayerInventory(source, items)
                TriggerClientEvent(Config.ClientEventPrefix .. 'InventoryNotify', source, 'remove', itemData, amount)
                return true
            end
        end

        -- If the slots with the item needs to be found
    else
        local slots = Core.Classes.Inventory.GetSlotsWithItem(source, item)
        local amountToRemove = amount
        if not slots then return false end

        for _, _slot in pairs(slots) do

            -- If they have more than what is being removed
            if items[_slot].amount > amountToRemove then
                items[_slot].amount = items[_slot].amount - amountToRemove
                Framework.Server.SavePlayerInventory(source, items)
                TriggerClientEvent(Config.ClientEventPrefix .. 'InventoryNotify', source, 'remove', itemData, amountToRemove)
                return true

                -- If the amount matches
            elseif items[_slot].amount == amountToRemove then
                items[_slot] = nil
                Framework.Server.SavePlayerInventory(source, items)
                TriggerClientEvent(Config.ClientEventPrefix .. 'InventoryNotify', source, 'remove', itemData, amountToRemove)
                return true
            end
        end
    end
    return false
end

exports("RemoveItem", Core.Classes.Inventory.RemoveItem)

-------------------------------------------------
--- Clears a player inventory
--- Server Event: ir8-inventory:Server:ClearInventory
--- Export: exports['ir8-inventory']:ClearInventory
-------------------------------------------------
function Core.Classes.Inventory.ClearInventory(source, filterItems)
	local items = {}

	if filterItems then
		local filterItemsType = type(filterItems)
		if filterItemsType == "string" then
			local item = Core.Classes.Inventory.GetSlotWithItem(source, filterItems)
			if item then items[item.slot] = item end
		elseif filterItemsType == "table" and table.type(filterItems) == "array" then
			for i = 1, #filterItems do
				local item = Core.Classes.Inventory.GetSlotWithItem(source, filterItems[i])
				if item then items[item.slot] = item end
			end
		end
	end

	Framework.Server.SavePlayerInventory(source, items)
end

exports("ClearInventory", Core.Classes.Inventory.ClearInventory)

-------------------------------------------------
--- Saves an external inventory
--- Server Event: ir8-inventory:Server:SaveExternalInventory
--- Export: exports['ir8-inventory']:SaveExternalInventory
-------------------------------------------------
function Core.Classes.Inventory.SaveExternalInventory (type, inventoryId, items)
	if not items then return false end
    items = Core.Classes.Inventory.ValidateItems(items)

    if type == 'drop' then
        local res = Core.Classes.Drops.SaveItems(inventoryId, items)
        if not res then return false end
        return true
    elseif type == "player" then
        return Core.Classes.Inventory.SavePlayerInventory(inventoryId, items)
    else
        local res = Framework.Server.SaveExternalInventory(type, inventoryId, items)
        if not res then return false end
        return true
    end
end

exports("SaveExternalInventory", Core.Classes.Inventory.SaveExternalInventory)

-------------------------------------------------
--- Loads an external inventory
--- Server Event: ir8-inventory:Server:LoadExternalInventory
--- Export: exports['ir8-inventory']:LoadExternalInventory
-------------------------------------------------
function Core.Classes.Inventory.LoadExternalInventory (type, typeId)

    -- If external type is shop
	if type == "shop" then
        local shop = Config.Shops[typeId]
        if not shop then return false end
        return Core.Classes.Shops.BuildItemList(shop.items)
    end

    -- If external type is stash
    if type == "stash" then
        local stash = Framework.Server.LoadExternalInventory(type .. "--" .. typeId)
        if not stash then return {} end
        local items = stash.items and json.decode(stash.items) or {}
        items = Core.Classes.Inventory.ValidateItems(items)
        return items
    end

    -- If external type is drop
    if type == "drop" then
        local drop = Core.Classes.Drops.Get(typeId)
        if not drop then return {} end
        local items = drop.items or {}
        items = Core.Classes.Inventory.ValidateItems(items)
        return items
    end

    -- If external type is player
    if type == "player" then
        local items = Core.Classes.Inventory.GetPlayerInventory(typeId) or {}
        return items
    end

    return false
end

exports("LoadExternalInventory", Core.Classes.Inventory.LoadExternalInventory)

-------------------------------------------------
--- Loads an external inventory and opens it
--- Server Event: ir8-inventory:Server:LoadExternalInventoryAndOpen
--- Export: exports['ir8-inventory']:LoadExternalInventoryAndOpen
-------------------------------------------------
function Core.Classes.Inventory.LoadExternalInventoryAndOpen(src, type, typeId)

    if not type then
        
        -- Check the name for the type, if it's not there, default to stash
        if typeId:find('stash') then
            type = 'stash'
        elseif typeId:find('trunk') then
            type = 'stash'
        elseif typeId:find('glovebox') then
            type = 'stash'
        elseif typeId:find('otherplayer') then
            type = 'player'
        else
            type = 'stash' 
        end
    end

    local items = Core.Classes.Inventory.LoadExternalInventory(type, typeId)
    Core.Classes.Inventory.OpenInventory(src, {
        type = type,
        id = typeId,
        name = type,
        items = items
    })
end

exports("LoadExternalInventoryAndOpen", Core.Classes.Inventory.LoadExternalInventoryAndOpen)

-------------------------------------------------
--- Performs swapping of items
-------------------------------------------------
function Core.Classes.Inventory.SwapSlots (src, invType, inventory, items)
    -- Is items a table
    if type(items) ~= "table" then return false end

    -- Is it empty
    if table.type(items) == "empty" then return false end

    -- Is it 2 items in length
    if Core.Utilities.TableLength(items) ~= 2 then return false end

    -- If item 1 is not found
    if not items[1].item then return false end

    -- If going to same spot, return false
    if tonumber(items[1].slot) == tonumber(items[1].newSlot) then return false end

    -- Set item 1
    local fromItem = Core.Classes.Inventory.Utilities.GetItemFromListByName(inventory, items[1].item.name, items[1].slot)
    if not fromItem then return false end

    -- Validate second item and find it
    local toItem = false
    if items[2].item then
        toItem = Core.Classes.Inventory.Utilities.GetItemFromListByName(inventory, items[2].item.name, items[2].slot)
    end

    -- Check for stacking
    local stack = false
    if toItem then
        if fromItem.name == toItem.name and not fromItem.unique then stack = true end
    end

    -- Set first item slot key
    local item1SlotKey = Core.Classes.Inventory.Utilities.GetSlotKeyForItemBySlotNumber(inventory, items[1].slot)
    if not item1SlotKey then return false end

    -- Set second item slot key
    local item2SlotKey = toItem and Core.Classes.Inventory.Utilities.GetSlotKeyForItemBySlotNumber(inventory, items[2].slot) or false

    -- If can stack, add amount and remove old slot
    if stack then
        if not item2SlotKey then return false end

        -- Add amount to second slot
        inventory[item2SlotKey].amount = tonumber(inventory[item2SlotKey].amount) + tonumber(inventory[item1SlotKey].amount)

        -- Remove the first slot
        table.remove(inventory, item1SlotKey)
    else

        -- Swap slot numbers
        if item2SlotKey then
            inventory[item2SlotKey].slot = items[2].newSlot
        end

        inventory[item1SlotKey].slot = items[1].newSlot
    end

    -- Return revised inventory
    return {
        success = true,
        inventory = inventory
    }
end

-------------------------------------------------
--- Performs swapping of items
-------------------------------------------------
function Core.Classes.Inventory.Transfer (src, origin, destination, item, destinationSlotId, originItems, destinationItems)
    -- Get loaded inventory items
    local inventoryItems = Core.Classes.Inventory:GetState("Items")
    if not item then return false end

    -- Validate that it is a real item
    local itemData = inventoryItems[item.name:lower()] or false
    if not itemData then return false end

    -- Get slot key of origin item
    local itemSlotKey = Core.Classes.Inventory.Utilities.GetSlotKeyForItemBySlotNumber(originItems, item.slot) or false
    if not itemSlotKey then return false end

    -- Check that target slot is empty
    local targetSlotHasItem = Core.Classes.Inventory.Utilities.GetSlotKeyForItemBySlotNumber(destinationItems, destinationSlotId) or false
    if targetSlotHasItem then return false end

    -- Set the slot, add the item to the destination, and remove from origin
    item.slot = destinationSlotId
    table.insert(destinationItems, item)
    table.remove(originItems, itemSlotKey)

    -- Return response
    return {
        success = true,
        originItems = originItems,
        destinationItems = destinationItems
    }
end

-------------------------------------------------
--- Move / Transfer Items
--- Server Event: ir8-inventory:Server:Move
--- Export: exports['ir8-inventory']:Move
-------------------------------------------------
function Core.Classes.Inventory.Move (src, data)
	local playerInventory = Core.Classes.Inventory.GetPlayerInventory(src)
    local inventoryItems = Core.Classes.Inventory:GetState("Items")

    -- If the action is to swap or move slots for an item
    if data.action == "swap" then

        if data.target == "inventory" then

            local res = Core.Classes.Inventory.SwapSlots(src, data.target, playerInventory, data.items)

            if res then 
                if res.success then
                    Core.Classes.Inventory.SavePlayerInventory(src, res.inventory)
                    return {success = true, items = Core.Classes.Inventory.GetPlayerInventory(src)}
                else
                    return {success = false, items = Core.Classes.Inventory.GetPlayerInventory(src)}
                end
            else
                return {success = false, items = Core.Classes.Inventory.GetPlayerInventory(src)}
            end

        elseif data.target == "external" then

            -- Loads the external inventory items
            local externalItems = Core.Classes.Inventory.LoadExternalInventory(data.external.type, data.external.id) or {}
            local res = Core.Classes.Inventory.SwapSlots(src, data.target, externalItems, data.items)

            if res then 
                if res.success then
                    Core.Classes.Inventory.SaveExternalInventory(data.external.type, data.external.id, res.inventory)
                    return {success = true, external = { items = res.inventory }}
                else
                    return {success = false, external = { items = externalItems }}
                end
            else
                return {success = false, external = { items = externalItems }}
            end

        end

    end

    -- If the action is to transfer
    if data.action == "transfer" then
        
        -- Get necessary variables first
        if not data.target then return false end
        if not data.external then return false end
        if type(data.external) ~= "table" then return false end

        -- Loads the external inventory items
        local externalItems = Core.Classes.Inventory.LoadExternalInventory(data.external.type, data.external.id) or {}

        -- If transfering from external to inventory
        if data.target == "inventory" then
            local res = Core.Classes.Inventory.Transfer(
                src,
                data.target == "inventory",
                data.target,
                data.item,
                data.toSlotId,
                externalItems,
                playerInventory
            )

            -- If drop becomes empty, remove it
            if data.external.type == "drop" then
                if Core.Utilities.TableLength(res.originItems) == 0 then
                    Core.Classes.Drops.Remove(data.external.id)
                end
            end

            if res then 
                if res.success then
                    Core.Classes.Inventory.SaveExternalInventory(data.external.type, data.external.id, res.originItems)
                    Core.Classes.Inventory.SavePlayerInventory(src, res.destinationItems)

                    return {
                        success = true,
                        items = Core.Classes.Inventory.GetPlayerInventory(src),
                        external = Core.Classes.Inventory.LoadExternalInventory(data.external.type, data.external.id) or {}
                    }
                else
                    return { 
                        success = false,
                        items = Core.Classes.Inventory.GetPlayerInventory(src),
                        external = Core.Classes.Inventory.LoadExternalInventory(data.external.type, data.external.id) or {}
                    }
                end
            else
                return { 
                    success = false,
                    items = Core.Classes.Inventory.GetPlayerInventory(src),
                    external = Core.Classes.Inventory.LoadExternalInventory(data.external.type, data.external.id) or {}
                }
            end
        end

        -- If transfering from inventory to external
        if data.target == "external" then
            local res = Core.Classes.Inventory.Transfer(
                src,
                data.target == "external",
                data.target,
                data.item,
                data.toSlotId,
                playerInventory,
                externalItems
            )

            if res then 
                if res.success then
                    Core.Classes.Inventory.SaveExternalInventory(data.external.type, data.external.id, res.destinationItems)
                    Core.Classes.Inventory.SavePlayerInventory(src, res.originItems)

                    return {
                        success = true,
                        items = Core.Classes.Inventory.GetPlayerInventory(src),
                        external = Core.Classes.Inventory.LoadExternalInventory(data.external.type, data.external.id) or {}
                    }
                else
                    return { 
                        success = false,
                        items = Core.Classes.Inventory.GetPlayerInventory(src),
                        external = Core.Classes.Inventory.LoadExternalInventory(data.external.type, data.external.id) or {}
                    }
                end
            else
                return { 
                    success = false,
                    items = Core.Classes.Inventory.GetPlayerInventory(src),
                    external = Core.Classes.Inventory.LoadExternalInventory(data.external.type, data.external.id) or {}
                }
            end
        end
    end

    -- Incorrect payload / action
    return false
end

exports("Move", Core.Classes.Inventory.Move)

-------------------------------------------------
--- Open Stash
-------------------------------------------------
function Core.Classes.Inventory.OpenStash (src, stashId)
    local Player = Framework.Server.GetPlayer(src)
    local stash = Config.Stashes[stashId]

    if not stash then
        return Core.Utilities.Log({
            type = "error",
            title = "OpenStash",
            message = "Stash[" .. stashId .. "] does not exist"
        })
    end

    local items = Core.Classes.Inventory.LoadExternalInventory('stash', stashId)

    Core.Classes.Inventory.OpenInventory(src, {
        type = "stash",
        id = stashId,
        name = stash.name,
        items = items
    })
end

exports("OpenStash", Core.Classes.Inventory.OpenStash)