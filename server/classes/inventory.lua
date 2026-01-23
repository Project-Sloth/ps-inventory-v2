Core.Classes.New("Inventory", { Items = {} })

-- Inventory utility methods
Core.Classes.Inventory.Utilities = {

    Notify = function (player, text, type)
        if Config.Notify == 'qb' then
            TriggerClientEvent("QBCore:Notify", player.PlayerData.source, text, type)
        elseif Config.Notify == 'ox' then
            lib.notify(player.PlayerData.source, { title = text, type = type})
        end
    end,

    -- Retrieve storage overrides for vehicle by hash key
    ---@param hashKey number
    ---@param storageType string
    GetVehicleSizeOverrideByHashKey = function (vehicleClass, hashKey, storageType)
        local data = nil

        -- Check class first
        for class, overrides in pairs(Config.Vehicles.ClassOverrides) do
            if class == tonumber(vehicleClass) then
                if overrides[storageType] then
                    data = overrides[storageType]
                end
            end
        end

        -- Then check model
        for model, overrides in pairs(Config.Vehicles.ModelOverrides) do
            if GetHashKey(model) == hashKey then
                if overrides[storageType] then
                    data = overrides[storageType]
                end
            end
        end

        return data
    end,

    -- Simple check if item is decayed or not
    ---@param item table
    IsItemDecayed = function (item)
        if not item.decay then return false end
        if not item.created then return false end
        local decayTime = (tonumber(item.decay) * 60)
        local expirationTime = tonumber(item.created) + decayTime
        if os.time() > expirationTime then return true end
        return false
    end,

    -- Gets percentage of decay left for item
    ---@param item table
    ItemDecayPercentage = function (item)
        if not item.decay then return 100 end
        if not item.created then return 100 end
        local decayTime = (tonumber(item.decay) * 60)
        local expirationTime = tonumber(item.created) + decayTime
        local decayBegin = item.created
        local decayEnd = expirationTime

        if os.time() > expirationTime then return 0 end
        local percentComplete = 100 - ((os.time() - decayBegin) / (decayEnd - decayBegin) * 100)
        if percentComplete < 0 then return 0 end
        if percentComplete > 100 then return 100 end
        return percentComplete
    end,

    -- Get the first empty slot in inventory
    ---@param items table
    ---@param numberOfSlots number
    GetFirstEmptySlot = function (items, numberOfSlots)
        local slotsOccupied = {}
        local newSlotKey = nil

        -- Enter item slots taken
        for _, item in pairs(items) do
            if item ~= nil then
                table.insert(slotsOccupied, tonumber(item.slot))
            end
        end

        -- Find first slot where not taken by either
        for slotKey = 1, numberOfSlots, 1 do
            if not Core.Utilities.TableHasValue(slotsOccupied, slotKey) then
                if not newSlotKey then newSlotKey = slotKey end
            end
        end

        return {
            key = Core.Utilities.TableLength(items) + 1,
            slot = newSlotKey
        }
    end,

    -- Get the slot key of an item's slot number
    ---@param items table
    ---@param slot number
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

    -- Get the slot by slot number
    ---@param items table
    ---@param slot number
    GetSlotBySlotNumber = function (items, slot)
        if not slot then return nil end
        slot = tonumber(slot)
        local res = nil

        for key, item in pairs(items) do
            if tonumber(item.slot) == slot then
                res = item
            end
        end

        return res
    end,

    -- Get a specific item from a list
    ---@param items table
    ---@param itemName string
    ---@param slot number
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
    ---@param slot number
    ---@param items table
    RemoveItemFromListBySlot = function (slot, items)
        for k, item in pairs(items) do
            if item.slot == slot then
                table.remove(items, k)
            end
        end

        return items
    end,

    -- Adds an item to the list
    ---@param items table
    ---@param item table
    ---@param slot number
    AddItemToList = function (items, item, slot)
        if slot then item.slot = slot end
        table.insert(items, item)
        return items
    end,

    -- Converts item to expected format
    ---@param item table
    ---@param additionalInfo? table
    ConvertItem = function (item, additionalInfo)

        -- Get original data
        local itemInfo = Core.Classes.Inventory:GetState("Items")[item.name]
        if not itemInfo then return nil end

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
            created = item.created or os.time(),
            decay = itemInfo.decay or false
        }

        -- Include ammo type
        if itemConverted.type == "weapon" then
            itemConverted.ammotype = itemInfo.ammotype or nil
        end

        -- Include decay information
        if itemConverted.decay then
            itemConverted.info.decayed = Core.Classes.Inventory.Utilities.IsItemDecayed(itemConverted)
            itemConverted.info.quality = Core.Classes.Inventory.Utilities.ItemDecayPercentage(itemConverted)
        end

        -- Include crafting data
        if itemInfo.crafting then
            itemConverted.crafting = itemInfo.crafting
        end

        -- Include placeable data
        if itemInfo.placeable then
            itemConverted.placeable = itemInfo.placeable
        end

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

-- Load Inventory Items
---@param init boolean
function Core.Classes.Inventory.Load(init)

    local inventoryItems = {}

    -- Only try to call this method if LoadFrameworkInventoryItems is true in config
    local frameworkItems = Config.LoadFrameworkInventoryItems and Framework.Server.GetInventoryItems() or {}

    -- Load items from this script
    local configItems = Config.Items

    -- Merge the tables
    inventoryItems = Core.Utilities.MergeTables(frameworkItems, configItems)

    Core.Classes.Inventory:UpdateState('Items', inventoryItems, function(items)
        Core.Utilities.Log({
            title = "Inventory Loaded",
            message = Core.Utilities.TableLength(items) .. " were loaded for inventory use"
        })
        
        if init then
            Core.Classes.Inventory.CreateUseables()

            -- Create useables for weapon class
            Core.Classes.Weapon.Init()
        end
    end)
end

-- Creates useables defined in useables.config.lua
function Core.Classes.Inventory.CreateUseables ()
    local items = Core.Classes.Inventory:GetState("Items") or {}

    for item, itemData in pairs(Config.Items) do
        if itemData.useable and itemData.onUse then
            if type(itemData.onUse) == "function" then
                Core.Classes.Inventory.CreateUseableItem(item, itemData.onUse)
            end
        end

        -- If item is placeable, but onUse is not provided, create it
        if itemData.placeable and not itemData.onUse then
            Core.Classes.Inventory.CreateUseableItem(item, function (source, item)
                Core.Classes.Placeables.Place(source, item)
            end)
        end
    end

    local registered = {}
    for _, itemName in pairs(Config.Weapons.AmmoItems) do
        if itemName and not registered[itemName] and items[itemName] then
            registered[itemName] = true
            Core.Classes.Inventory.CreateUseableItem(itemName, function (source)
                TriggerClientEvent(Config.ClientEventPrefix .. 'ReloadWeapon', source)
            end)
        end
    end

    for itemName, itemData in pairs(items) do
        local isWeapon = itemData.type == "weapon" or (type(itemName) == "string" and itemName:sub(1, 7) == "weapon_")
        if itemData.useable and not isWeapon then
            if not Framework.Server.GetUseableItem(itemName) then
                local label = itemData.label or itemName
                Core.Classes.Inventory.CreateUseableItem(itemName, function (source)
                    local player = Framework.Server.GetPlayer(source)
                    if player then
                        Core.Classes.Inventory.Utilities.Notify(player, (label .. " has no use action configured"), "error")
                    end
                end)
            end
        end
    end
end

-- Sync player inventors to database
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

-- Validate Items
---@param items table
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
    if table.type(items) == "empty" then return inventory end

    -- Iterate through items and setup inventory to return
    for _, item in pairs(items) do
        if item then
            local itemConverted = Core.Classes.Inventory.Utilities.ConvertItem(item)
            if itemConverted then table.insert(inventory, itemConverted) end
        end
    end

    return inventory
end

-- Retrieve all available inventory items
-- Export: exports['ps-inventory']:Items()
function Core.Classes.Inventory.Items()
    return Core.Classes.Inventory:GetState('Items')
end

-- Check if item exists
-- Export: exports['ps-inventory']:ItemExists(item)
---@param item table
function Core.Classes.Inventory.ItemExists(item)
    if not Core.Classes.Inventory:GetState('Items')[item] then return false end
    return true
end

-- Get player inventory
-- Export: exports['ps-inventory']:GetPlayerInventory(src)
---@param src number
function Core.Classes.Inventory.GetPlayerInventory(src)

    local inventory = Framework.Server.GetPlayerInventory(src)
    if not inventory then return {} end

    -- Validate and return inventory
    return Core.Classes.Inventory.ValidateItems(inventory)
end

-- Saves player inventory
-- Export: exports['ps-inventory']:SavePlayerInventory(src, offline)
---@param src number
---@param inventory table
function Core.Classes.Inventory.SavePlayerInventory(src, inventory)

    if inventory == nil then
        inventory = Framework.Server.GetPlayerInventory(src)
    end

    -- Validate and return inventory
    inventory = Core.Classes.Inventory.ValidateItems(inventory)

    -- Save player inventory
    return Framework.Server.SavePlayerInventory(src, inventory)
end

-- Calculate weight of inventory
-- Export: exports['ps-inventory']:GetTotalWeight(items)
---@param items table
function Core.Classes.Inventory.GetTotalWeight(items)
    local weight = 0
    if not items then return 0 end

    for _, item in pairs(items) do
        if item then
            weight = weight + (item.weight * (item.amount or 1))
        end
    end

    return tonumber(weight)
end

-- See if player has item (or amount of)
-- Export: exports['ps-inventory']:HasItem(items)
---@param source number
---@param items table
---@param count number
function Core.Classes.Inventory.HasItem(source, items, count)
    return Framework.Server.HasItem(source, items, count)
end

-- Get slot of inventory and return the item
-- Export: exports['ps-inventory']:GetSlot(src, slot)
---@param src number
---@param slot number
function Core.Classes.Inventory.GetSlot(src, slot)
    local inventory = Core.Classes.Inventory.GetPlayerInventory(src)
    slot = tonumber(slot)
    local slotKey = false

    for k, item in pairs(inventory) do
        if tonumber(item.slot) == tonumber(slot) then
            slotKey = k
        end
    end

    if not slotKey then return false end
    return inventory[slotKey]
end

-- Get player slot number with item
-- Export: exports['ps-inventory']:GetSlotNumberWithItem(src, item)
---@param src number
---@param itemName string
function Core.Classes.Inventory.GetSlotNumberWithItem(src, itemName)
    local inventory = Core.Classes.Inventory.GetPlayerInventory(src)

    for slot, item in pairs(inventory) do
        if item.name:lower() == itemName:lower() then
            return tonumber(slot)
        end
    end

    return nil
end

-- Get player slot with item
-- Export: exports['ps-inventory']:GetSlotWithItem(src, item)
---@param src number
---@param itemName string
---@param items table
function Core.Classes.Inventory.GetSlotWithItem(src, itemName, items)
    local inventory = items and items or Core.Classes.Inventory.GetPlayerInventory(src)

    for slot, item in pairs(inventory) do
        if item.name:lower() == itemName:lower() then
            return item
        end
    end

    return nil
end

-- Get player slots with item
-- Export: exports['ps-inventory']:GetSlotsWithItem(src, item)
-- returnType = "slots" or "keys" | Defaults to "keys"
---@param src number
---@param itemName string
---@param returnType string
function Core.Classes.Inventory.GetSlotsWithItem(src, itemName, returnType)
    returnType = returnType or 'keys'
    local inventory = Core.Classes.Inventory.GetPlayerInventory(src)
    local slots = {}

    for slot, item in pairs(inventory) do
        if item.name:lower() == itemName:lower() then
            table.insert(slots, returnType == 'slots' and item.slot or slot)
        end
    end

    return slots
end

-- Open player inventory
-- Export: exports['ps-inventory']:OpenInventory(src)
---@param src number
---@param external? table
function Core.Classes.Inventory.OpenInventory(src, external)
    TriggerClientEvent(Config.ClientEventPrefix .. 'OpenInventory', src, external)
end

-- Open target player inventory
-- Export: exports['ps-inventory']:OpenInventoryById(src, target)
---@param src number
---@param target number
function Core.Classes.Inventory.OpenInventoryById(src, targetSrc)
    if src == target then 
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Inventory.OpenInventoryById",
            message = "Source " .. src .. " attempted to open their own inventory"
        })

        return false 
    end

    local player = Framework.Server.GetPlayer(src)
    if not player then 
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Inventory.OpenInventoryById",
            message = "Unable to retrieve player information for source: " .. src
        })

        return false 
    end

    local target = Framework.Server.GetPlayer(targetSrc)
    if not target then 
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Inventory.OpenInventoryById",
            message = "Unable to retrieve target information for source: " .. targetSrc
        })

        return false 
    end

    Core.Classes.Inventory.CloseInventory(targetSrc)

    if not Player(targetSrc).state.inventoryBusy then
        Player(targetSrc).state.inventoryBusy = true
    end

    local items = Core.Classes.Inventory.LoadExternalInventory('player', targetSrc)
    return Core.Classes.Inventory.OpenInventory(src, {
        type = "player",
        id = targetSrc,
        name = Framework.Server.GetPlayerName(src),
        slots = #items,
        items = items,
        weight = Config.Inventories.Player.MaxWeight
    })
end

-- Close player inventory
-- Export: exports['ps-inventory']:CloseInventory(src)
---@param src number
function Core.Classes.Inventory.CloseInventory(src)
    TriggerClientEvent(Config.ClientEventPrefix .. 'CloseInventory', src)
end

-- Creats a useable item
-- Export: exports['ps-inventory']:CreateUseableItem(itemName, data)
---@param itemName string
---@param data table
function Core.Classes.Inventory.CreateUseableItem(itemName, data)
	Framework.Server.CreateUseableItem(itemName, data)
end

-- Validates item then uses it
-- Export: exports['ps-inventory']:ValidateAndUseItem(src, itemData)
---@param src number
---@param itemData table
function Core.Classes.Inventory.ValidateAndUseItem(src, itemData)
    if itemData then
        local itemInfo = Core.Classes.Inventory:GetState("Items")[itemData.name]
        local isWeapon = itemData.type == "weapon" or (type(itemData.name) == "string" and itemData.name:sub(1, 7) == "weapon_")

        -- Handle weapon types
        if isWeapon then

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

            -- If item is decayed
            if Core.Classes.Inventory.Utilities.IsItemDecayed(itemData) then
                return false
            end

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

-- Uses an item if applicable
-- Export: exports['ps-inventory']:UseItem(item)
---@param item table
function Core.Classes.Inventory.UseItem(item, ...)
    local itemData = Framework.Server.GetUseableItem(item)
    local callback = type(itemData) == 'table' and
                         (rawget(itemData, '__cfx_functionReference') and itemData or itemData.cb or itemData.callback or itemData.func) or
                         type(itemData) == 'function' and itemData
    if not callback then
        return Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Inventory.UseItem",
            message = ("Unable to use item '%s', no callback found."):format(tostring(item))
        })
    end

    callback(...)
end

-- Checks if player can carry weight of new item
-- Export: exports['ps-inventory']:CanCarryItem
---@param source number
---@param item string
---@param amount number
---@param maxWeight? number
function Core.Classes.Inventory.CanCarryItem (source, item, amount, maxWeight)

    -- Player information
    local player = Framework.Server.GetPlayer(source)
    if not player then 
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Inventory.CanCarryItem",
            message = "Unable to retrieve player information for source: " .. source
        })

        return false 
    end

    local items = Core.Classes.Inventory.GetPlayerInventory(source)

    -- Get the total weight of the inventory
    local totalWeight = Core.Classes.Inventory.GetTotalWeight(items)

    -- Get the item information
    local itemInfo = Core.Classes.Inventory:GetState('Items')[item:lower()]

    -- Set the quanity
    amount = tonumber(amount) or 1

    -- Check the weight with the new item
    if (totalWeight + (itemInfo.weight * amount)) <= (maxWeight and maxWeight or Config.Inventories.Player.MaxWeight) then
        return true
    end
    
    return false
end

-- Sets new amount for an item
---@param source number
---@param itemName string
---@param count number
function Core.Classes.Inventory.SetItem(source, itemName, count)
    local player = Framework.Server.GetPlayer(source)

    if not player then 
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Inventory.SetItem",
            message = "Unable to retrieve player information for source: " .. source
        })

        return false 
    end

    if itemName and count >= 0 then
        local slot = Core.Classes.Inventory.GetSlotWithItem(source, itemName)

        if slot then
            Core.Classes.Inventory.RemoveItem(source, slot.name, slot.amount, nil, true)
        end

        return Core.Classes.Inventory.AddItem(
            source, 
            itemName, 
            count, 
            nil, 
            nil, 
            nil,
            nil,
            true
        )
    end
end

-- Adds an item to the inventory
-- Export: exports['ps-inventory']:AddItem
---@param source number
---@param item string
---@param amount number
---@param slot? number
---@param info? table
---@param reason? string
---@param created? number
function Core.Classes.Inventory.AddItem(source, item, amount, slot, info, reason, created, ignoreNotification, doNotStack)

    -- Player information
    local player = Framework.Server.GetPlayer(source)

    if not player then 
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Inventory.AddItem",
            message = "Unable to retrieve player information for source: " .. source
        })

        return false 
    end

    local items = Core.Classes.Inventory.GetPlayerInventory(source)

    -- Get the total weight of the inventory
    local totalWeight = Core.Classes.Inventory.GetTotalWeight(items)

    -- Get the item information
    local itemInfo = Core.Classes.Inventory:GetState('Items')[item:lower()]

    -- If the item does not exist, or the
    if not itemInfo then 
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Inventory.AddItem",
            message = "Unable to retrieve item data for : " .. item:lower()
        })

        return false 
    end

    -- Set the quanity
    amount = tonumber(amount) or 1

    -- Set the slot number, or if it exists get that slot number
    slot = tonumber(slot) or Core.Classes.Inventory.GetSlotNumberWithItem(source, item)

    -- If created time is passed, set it
    if created then itemInfo.created = created end

    -- Make sure info is a table
    info = type(info) == "table" and Core.Utilities.MergeTables((itemInfo.info or {}), info) or {}

    -- If is a weapon, set the serial number and quality
    if itemInfo.type == 'weapon' then
        info.serie = info.serie or Core.Utilities.GenerateSerialNumber()
    end

    -- Check the weight with the new item
    if (totalWeight + (itemInfo.weight * amount)) <= Config.Inventories.Player.MaxWeight then

        -- If forced not to stack, use this logic and skip everything else
        if doNotStack then

            local availableSlot = Core.Classes.Inventory.Utilities.GetFirstEmptySlot(items, Config.Inventories.Player.MaxSlots)
            if not availableSlot then return false end

            items[availableSlot.key] = Core.Classes.Inventory.Utilities.ConvertItem(itemInfo, {
                slot = availableSlot.slot,
                info = info or {},
                amount = amount
            })

            if not ignoreNotification then
                TriggerClientEvent(Config.ClientEventPrefix .. 'InventoryNotify', source, 'add', itemInfo, amount)
            end

            Framework.Server.SavePlayerInventory(source, items)

            if player.Offline then return true end
            return true
        end

        -- If stackable
        if (slot and items[slot]) and (items[slot].name:lower() == item:lower()) and
            (itemInfo.type == 'item' and not itemInfo.unique) then

            -- If decay of existing item is not fresh, add to new slot
            if items[slot].info.quality ~= info.quality then
                local availableSlot = Core.Classes.Inventory.Utilities.GetFirstEmptySlot(items, Config.Inventories.Player.MaxSlots)
                if not availableSlot then return false end

                items[availableSlot.key] = Core.Classes.Inventory.Utilities.ConvertItem(itemInfo, {
                    slot = availableSlot.slot,
                    info = info or {},
                    amount = amount
                })

                if not ignoreNotification then
                    TriggerClientEvent(Config.ClientEventPrefix .. 'InventoryNotify', source, 'add', itemInfo, amount)
                end

                Framework.Server.SavePlayerInventory(source, items)
                if player.Offline then return true end

                return true

            -- Go ahead with stacking if decay check passed
            else
                items[slot].amount = items[slot].amount + amount

                if not ignoreNotification then
                    TriggerClientEvent(Config.ClientEventPrefix .. 'InventoryNotify', source, 'add', itemInfo, amount)
                end

                Framework.Server.SavePlayerInventory(source, items)
                if player.Offline then return true end

                return true
            end

        -- If slot is available
        elseif not itemInfo.unique and slot or slot and items[slot] == nil then
            items[slot] = Core.Classes.Inventory.Utilities.ConvertItem(itemInfo, {
                slot = slot,
                info = info or {},
                amount = amount
            })

            if not ignoreNotification then
                TriggerClientEvent(Config.ClientEventPrefix .. 'InventoryNotify', source, 'add', itemInfo, amount)
            end

            Framework.Server.SavePlayerInventory(source, items)
            if player.Offline then return true end

            return true

        -- If not stackable
        elseif itemInfo.unique or (not slot or slot == nil) or itemInfo.type == 'weapon' or doNotStack then

            local availableSlot = Core.Classes.Inventory.Utilities.GetFirstEmptySlot(items, Config.Inventories.Player.MaxSlots)
            if not availableSlot then return false end

            items[availableSlot.key] = Core.Classes.Inventory.Utilities.ConvertItem(itemInfo, {
                slot = availableSlot.slot,
                info = info or {},
                amount = amount
            })

            if not ignoreNotification then
                TriggerClientEvent(Config.ClientEventPrefix .. 'InventoryNotify', source, 'add', itemInfo, amount)
            end

            Framework.Server.SavePlayerInventory(source, items)

            if player.Offline then return true end
            return true
        end
    else
        Core.Classes.Inventory.Utilities.Notify(player, Core.Language.Locale('overweight'), 'error')
    end

    return false
end

-- Remove an item from inventory
-- Export: exports['ps-inventory']:RemoveItem
---@param source number
---@param item string
---@param amount number
---@param slot? number
function Core.Classes.Inventory.RemoveItem(source, item, amount, slot, ignoreNotification)

    -- Validate player
    local player = Framework.Server.GetPlayer(source)

    if not player then 
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Inventory.RemoveItem",
            message = "Unable to retrieve player information for source: " .. source
        })

        return false 
    end

    -- Get player inventory
    local items = Core.Classes.Inventory.GetPlayerInventory(source)

    -- Validate item
    local itemData = Core.Classes.Inventory:GetState("Items")[item:lower()]
    if not itemData then 
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Inventory.RemoveItem",
            message = "Unable to retrieve item data for: " .. item:lower()
        })

        return false
    end

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

                if not ignoreNotification then
                    TriggerClientEvent(Config.ClientEventPrefix .. 'InventoryNotify', source, 'remove', itemData, amount)
                end

                return true

            -- If the amount is less or equal
            else
                items[slotKey] = nil
                Framework.Server.SavePlayerInventory(source, items)

                if not ignoreNotification then
                    TriggerClientEvent(Config.ClientEventPrefix .. 'InventoryNotify', source, 'remove', itemData, amount)
                end

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

                if not ignoreNotification then
                    TriggerClientEvent(Config.ClientEventPrefix .. 'InventoryNotify', source, 'remove', itemData, amountToRemove)
                end

                return true

            -- If the amount is less or equal
            else
                items[_slot] = nil
                Framework.Server.SavePlayerInventory(source, items)

                if not ignoreNotification then
                    TriggerClientEvent(Config.ClientEventPrefix .. 'InventoryNotify', source, 'remove', itemData, amountToRemove)
                end

                return true
            end
        end
    end

    return false
end

function Core.Classes.Inventory.UpdateItem(source, slot, itemData)
    -- Validate player
    local player = Framework.Server.GetPlayer(source)

    if not player then 
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Inventory.UpdateItem",
            message = "Unable to retrieve player information for source: " .. source
        })

        return false 
    end

    -- Get player inventory
    local items = Core.Classes.Inventory.GetPlayerInventory(source)

    -- Get slot key
    local slotKey = Core.Classes.Inventory.Utilities.GetSlotKeyForItemBySlotNumber(items, slot)
    if not slotKey then 
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Inventory.UpdateItem",
            message = "Unable to retrieve slotKey for slot: " .. slot
        })

        return false 
    end

    -- Override item data
    items[slotKey] = itemData

    -- Update inventory
    Framework.Server.SavePlayerInventory(source, items)

    -- Return a response
    return true
end

-- Clears a player inventory
-- Export: exports['ps-inventory']:ClearInventory
---@param source number
---@param filterItems? table
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

-- Saves an external inventory
-- Export: exports['ps-inventory']:SaveExternalInventory
---@param type string
---@param inventoryId string
---@param items table
function Core.Classes.Inventory.SaveExternalInventory (type, inventoryId, items)
	if not items then 
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Inventory.SaveExternalInventory",
            message = "Parameter 3 (items) is required"
        })

        return false 
    end

    items = Core.Classes.Inventory.ValidateItems(items)

    if type == 'drop' then
        local res = Core.Classes.Drops.SaveItems(inventoryId, items)

        if not res then 
            Core.Utilities.Log({
                type = "error",
                title = "Core.Classes.Inventory.SaveExternalInventory",
                message = "Unable to save items for drop " .. inventoryId
            })

            return false 
        end

        return true
    elseif type == "player" then
        return Core.Classes.Inventory.SavePlayerInventory(inventoryId, items)
    else
        local res = Framework.Server.SaveExternalInventory(type, inventoryId, items)

        if not res then 
            Core.Utilities.Log({
                type = "error",
                title = "Core.Classes.Inventory.SaveExternalInventory",
                message = "Unable to save items for external inventory: " .. inventoryId
            })

            return false 
        end

        return true
    end
end

-- Loads an external inventory
-- Export: exports['ps-inventory']:LoadExternalInventory
---@param type string
---@param typeId string
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

    Core.Utilities.Log({
        type = "error",
        title = "Core.Classes.Inventory.LoadExternalInventory",
        message = "Invalid type passed"
    })

    return false
end

-- Loads an external inventory and opens it
-- Export: exports['ps-inventory']:LoadExternalInventoryAndOpen
---@param src number
---@param type string
---@param typeId string
---@param typeData? table
function Core.Classes.Inventory.LoadExternalInventoryAndOpen(src, type, typeId, typeData)

    local slots = Config.Inventories.Stash.MaxSlots
    local weight = Config.Inventories.Stash.MaxWeight
    local name = type

    -- If type is not provided, find the type (framework compatibility)
    if not type then
        
        -- Check the name for the type, if it's not there, default to stash
        if typeId:find('otherplayer') then
            type = 'player'
            slots = Config.Glovebox.Player.MaxSlots
            weight = Config.Glovebox.Player.MaxWeight
            name = "Player"
        else
            type = 'stash'
            name = "Stash"
        end
    else

        -- If external type is trunk
        if type == "stash" then

            -- Check the name for the type, if it's not there, default to stash
            if typeId:find('trunk') then
                slots = Config.Inventories.Trunk.MaxSlots
                weight = Config.Inventories.Trunk.MaxWeight

                -- Overrides check
                local overrides = Core.Classes.Inventory.Utilities.GetVehicleSizeOverrideByHashKey(typeData.class, typeData.model, 'Trunk')
                if overrides then
                    if overrides.MaxSlots then slots = overrides.MaxSlots end
                    if overrides.MaxWeight then weight = overrides.MaxWeight end
                end

                name = "Trunk"

                if slots == 0 then return false end
            elseif typeId:find('glovebox') then
                slots = Config.Inventories.Glovebox.MaxSlots
                weight = Config.Inventories.Glovebox.MaxWeight

                -- Overrides check
                local overrides = Core.Classes.Inventory.Utilities.GetVehicleSizeOverrideByHashKey(typeData.class, typeData.model, 'Glovebox')
                if overrides then
                    if overrides.MaxSlots then slots = overrides.MaxSlots end
                    if overrides.MaxWeight then weight = overrides.MaxWeight end
                end

                name = "Glovebox"

                if slots == 0 then return false end
            else
                type = 'stash'
                name = "Stash"
            end
        end

        -- If external type is drop
        if type == "drop" then
            slots = Config.Inventories.Drop.MaxSlots
            weight = Config.Inventories.Drop.MaxWeight
            name = "Drop"
        end

        -- If external type is player
        if type == "player" then
            slots = Config.Inventories.Player.MaxSlots
            weight = Config.Inventories.Player.MaxWeight
            name = "Player"
        end
    end

    local items = Core.Classes.Inventory.LoadExternalInventory(type, typeId)

    -- Item check for drops
    if type == "drop" and Core.Utilities.TableLength(items) == 0 then
        return Core.Classes.Inventory.OpenInventory(src, false)
    end

    Core.Classes.Inventory.OpenInventory(src, {
        type = type,
        id = typeId,
        name = name,
        items = items,
        slots = slots,
        weight = weight
    })
end

-- Performs swapping of items
---@param src number
---@param invType string
---@param inventory table
---@param items table
function Core.Classes.Inventory.SwapSlots (src, invType, inventory, items)
    -- Is items a table
    if type(items) ~= "table" then 
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Inventory.SwapSlots",
            message = "Parameter items is expected to be a table"
        })

        return false 
    end

    -- Is it empty
    if table.type(items) == "empty" then 
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Inventory.SwapSlots",
            message = "Parameter items should not be empty"
        })

        return false 
    end

    -- Is it 2 items in length
    if Core.Utilities.TableLength(items) ~= 2 then 
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Inventory.SwapSlots",
            message = "Parameter items should be a table with 2 items"
        })

        return false 
    end

    -- If item 1 is not found
    if not items[1].item then 
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Inventory.SwapSlots",
            message = "items[1].item should be provided"
        })

        return false 
    end

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

        -- Match quality
        if inventory[item2SlotKey].info and inventory[item1SlotKey].info then
            if inventory[item2SlotKey].info.quality ~= inventory[item1SlotKey].info.quality then
                return false
            end
        end

        -- Add amount to second slot
        inventory[item2SlotKey].amount = tonumber(inventory[item2SlotKey].amount) + tonumber(inventory[item1SlotKey].amount)

        -- Remove the first slot
        table.remove(inventory, item1SlotKey)
    else

        -- Swap slot numbers
        if item2SlotKey then inventory[item2SlotKey].slot = items[2].newSlot end
        inventory[item1SlotKey].slot = items[1].newSlot
    end

    -- Return revised inventory
    return {
        success = true,
        inventory = inventory
    }
end

-- Performs swapping of items
---@param src number
---@param origin string
---@param destination string
---@param item table
---@param destinationSlotId number
---@param originItems number
---@param destinationItems number
function Core.Classes.Inventory.Transfer (src, origin, destination, item, destinationSlotId, originItems, destinationItems)
    -- Get loaded inventory items
    local inventoryItems = Core.Classes.Inventory:GetState("Items")

    if not item then 
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Inventory.Transfer",
            message = "Invalid payload for item"
        })

        return false 
    end

    -- Validate that it is a real item
    local itemData = inventoryItems[item.name:lower()] or false
    if not itemData then 
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Inventory.Transfer",
            message = "Unable to find specified item in server inventory items list"
        })

        return false 
    end

    -- Get slot key of origin item
    local itemSlotKey = Core.Classes.Inventory.Utilities.GetSlotKeyForItemBySlotNumber(originItems, item.slot) or false

    if not itemSlotKey then 
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Inventory.Transfer",
            message = "Unable to find slotKey for item"
        })

        return false 
    end

    -- Check that target slot is empty
    local targetSlotHasItem = Core.Classes.Inventory.Utilities.GetSlotBySlotNumber(destinationItems, destinationSlotId) or false

    -- Check to see if an item is in that slot.
    if targetSlotHasItem then

        -- Stack the item if can be stacked
        if targetSlotHasItem.name == item.name and not item.unique then
            local destinationSlotKey = Core.Classes.Inventory.Utilities.GetSlotKeyForItemBySlotNumber(destinationItems, destinationSlotId) or false
            if not destinationSlotKey then return false end

            -- Match quality
            if destinationItems[destinationSlotKey].info and item.info then
                if destinationItems[destinationSlotKey].info.quality ~= item.info.quality then
                    return false
                end
            end

            destinationItems[destinationSlotKey].amount = tonumber(destinationItems[destinationSlotKey].amount) + tonumber(item.amount)
        else

            -- Slot is taken and is not the same
            return false
        end
    else
        -- Set the slot, add the item to the destination, and remove from origin
        item.slot = destinationSlotId
        table.insert(destinationItems, item)
    end

    -- Remove old item from origin items
    table.remove(originItems, itemSlotKey)

    -- Return response
    return {
        success = true,
        originItems = originItems,
        destinationItems = destinationItems
    }
end

-- Move / Transfer Items
---@param src number
---@param data table
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
                    return {success = true, external = res.inventory}
                else
                    return {success = false, external = externalItems}
                end
            else
                return {success = false, external = externalItems}
            end

        end

    end

    -- If the action is to transfer
    if data.action == "transfer" then
        
        -- Get necessary variables first
        if not data.target then 
            Core.Utilities.Log({
                type = "error",
                title = "Core.Classes.Inventory.Move",
                message = "Invalid payload for data.target"
            })

            return false 
        end

        if not data.external then
            Core.Utilities.Log({
                type = "error",
                title = "Core.Classes.Inventory.Move",
                message = "Invalid payload for data.external"
            })

            return false 
        end

        if type(data.external) ~= "table" then 
            Core.Utilities.Log({
                type = "error",
                title = "Core.Classes.Inventory.Move",
                message = "Invalid payload for data.external"
            })

            return false 
        end

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

            if data.item.name == "money" then
                Framework.Server.AddMoney(src, 'cash', data.item.amount)
            end

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

                    if data.external.type == "player" then
                        TriggerClientEvent(Config.ClientEventPrefix .. 'InventoryNotify', data.external.id, 'remove', data.item, data.item.amount)
                    end

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

            if data.item.name == "money" then
                Framework.Server.RemoveMoney(src, 'cash', data.item.amount)
            end

            if res then 
                if res.success then
                    Core.Classes.Inventory.SaveExternalInventory(data.external.type, data.external.id, res.destinationItems)
                    Core.Classes.Inventory.SavePlayerInventory(src, res.originItems)

                    if data.external.type == "player" then
                        TriggerClientEvent(Config.ClientEventPrefix .. 'InventoryNotify', data.external.id, 'add', data.item, data.item.amount)
                    end

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

-- Split Item
---@param src number
---@param data table
function Core.Classes.Inventory.Split (src, data)

    if not data then 
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Inventory.Split",
            message = "Invalid payload for data"
        })

        return { success = false }
    end

    Core.Classes.Inventory.AddItem(src, data.item.name, data.item.amount, nil, data.item.info, nil, data.item.created, true, true)
    Core.Classes.Inventory.RemoveItem(src, data.item.name, data.item.amount, data.item.slot, true)
    return { success = true }
end

-- Give Item
---@param src number
---@param data table
function Core.Classes.Inventory.Give (src, data)
    local playerInventory = Core.Classes.Inventory.GetPlayerInventory(src)
    local inventoryItems = Core.Classes.Inventory:GetState("Items")

    -- Get player coords
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)

    -- Get the closest player
    local closestPlayer = data.playerId
    if not closestPlayer then return { success = false, message = "No nearby players" } end
    if closestPlayer == src then return { success = false, message = "No nearby players" } end

    local removed = Core.Classes.Inventory.RemoveItem(src, data.item.name, data.item.amount, data.item.slot)
    if not removed then return { success = false } end

    Core.Classes.Inventory.AddItem(closestPlayer, data.item.name, data.item.amount, nil, data.item.info, nil, data.item.created)
    return { success = true }
end

-- Open Stash
-- Export: exports['ps-inventory']:OpenStash(src, stashId)
---@param src number
---@param stashId string
function Core.Classes.Inventory.OpenStash (src, stashId)
    local player = Framework.Server.GetPlayer(src)
    local stash = Config.Stashes[stashId]

    if not stash then
        return Core.Utilities.Log({
            type = "error",
            title = "OpenStash",
            message = "Stash[" .. stashId .. "] does not exist"
        })
    end

    local slots = Config.Inventories.Stash.MaxSlots
    local weight = Config.Inventories.Stash.MaxWeight

    if stash.slots then slots = stash.slots end
    if stash.weight then weight = stash.weight end

    local items = Core.Classes.Inventory.LoadExternalInventory('stash', stashId)

    Core.Classes.Inventory.OpenInventory(src, {
        type = "stash",
        id = stashId,
        name = stash.name,
        items = items,
        slots = slots,
        weight = weight
    })
end


-- Define available exports for Inventory
exports("Items", Core.Classes.Inventory.Items)
exports("ItemExists", Core.Classes.Inventory.ItemExists)
exports("GetPlayerInventory", Core.Classes.Inventory.GetPlayerInventory)
exports("SaveInventory", Core.Classes.Inventory.SaveInventory)
exports("SavePlayerInventory", Core.Classes.Inventory.SaveInventory)
exports("GetTotalWeight", Core.Classes.Inventory.GetTotalWeight)
exports("HasItem", Core.Classes.Inventory.HasItem)
exports("GetSlot", Core.Classes.Inventory.GetSlot)
exports("GetSlotNumberWithItem", Core.Classes.Inventory.GetSlotNumberWithItem)
exports("GetSlotWithItem", Core.Classes.Inventory.GetSlotWithItem)
exports("GetSlotsWithItem", Core.Classes.Inventory.GetSlotsWithItem)
exports("OpenInventory", Core.Classes.Inventory.OpenInventory)
exports("OpenInventoryById", Core.Classes.Inventory.OpenInventoryById)
exports("CloseInventory", Core.Classes.Inventory.CloseInventory)
exports("CreateUseableItem", Core.Classes.Inventory.CreateUseableItem)
exports("ValidateAndUseItem", Core.Classes.Inventory.ValidateAndUseItem)
exports("UseItem", Core.Classes.Inventory.UseItem)
exports("CanCarryItem", Core.Classes.Inventory.CanCarryItem)
exports("SetItem", Core.Classes.Inventory.SetItem)
exports("AddItem", Core.Classes.Inventory.AddItem)
exports("RemoveItem", Core.Classes.Inventory.RemoveItem)
exports("ClearInventory", Core.Classes.Inventory.ClearInventory)
exports("SaveExternalInventory", Core.Classes.Inventory.SaveExternalInventory)
exports("LoadExternalInventory", Core.Classes.Inventory.LoadExternalInventory)
exports("LoadExternalInventoryAndOpen", Core.Classes.Inventory.LoadExternalInventoryAndOpen)
exports("Move", Core.Classes.Inventory.Move)
exports("OpenStash", Core.Classes.Inventory.OpenStash)
