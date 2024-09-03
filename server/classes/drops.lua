Core.Classes.New("Drops", { Drops = {} })

-- Creates a new drop
---@param source number
---@param data table
function Core.Classes.Drops.Create (source, data)

    -- Log initiation
    Core.Utilities.Log({
        title = "Drops.Create",
        message = "Creation of drop was initiated"
    })

    -- Validate item
    local inventory = Core.Classes.Inventory.GetPlayerInventory(source)
    local itemData = Core.Classes.Inventory.Utilities.GetItemFromListByName(inventory, data.item.name, data.item.slot) or false

    if not itemData then 
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Drops.Create",
            message = "Unable to find item " .. data.item.name .. " data"
        })

        return { success = false } 
    end

    -- Validate ped exists
    local ped = GetPlayerPed(source)

    if not DoesEntityExist(ped) then 
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Drops.Create",
            message = "Unable to verify that entity exists"
        })

        return { success = false } 
    end

    -- Get player coords
    local playerCoords = GetEntityCoords(ped)

    local dropId = nil

    -- Match amount to amount specified
    itemData.amount = data.item.amount

    -- If a drop id is supplied, first verify it exists,
    -- then add to the item.
    if data.dropId then
        
        -- Verify it exists
        local dropData = Core.Classes.Drops.Get(data.dropId)
        if dropData then
            dropId = data.dropId
            local res = Core.Classes.Drops.AddItem(source, data.dropId, itemData)
            if not res then return { success = false } end
        end
    end
    
    if not dropId then
        -- Set item to be sent to drop
        local dropItem = itemData
        dropItem.slot = 1

        -- Generate drop id
        dropId = Core.Utilities.GenerateDropId()
        Core.Utilities.Log({
            title = "Drops.Create",
            message = "Generated drop id: " .. dropId
        })

        -- Retrieve current drops
        local drops = Core.Classes.Drops:GetState('Drops')

        -- Create new drop
        table.insert(drops, {
            id = dropId,
            location = playerCoords,
            created = os.time(),
            expiration = (Config.Drops.ExpirationTime) + os.time(),
            items = { dropItem }
        })

        if dropItem.name == "money" then
            Framework.Server.RemoveMoney(source, 'cash', dropItem.amount)
        end

        -- Update state
        Core.Classes.Drops:UpdateState('Drops', drops)
    end

    -- Verify it was created
    local dropData = Core.Classes.Drops.Get(dropId)
    if not dropData then
        Core.Utilities.Log({
            title = "Drops.Create",
            message = "Could not find drop data"
        })
        return { success = false }
    end

    -- Remove from player
    Core.Classes.Inventory.RemoveItem(source, data.item.name, data.item.amount, data.item.slot)

    -- Send drops data to everyone
    Core.Classes.Drops.Beacon()

    -- Return new drop data
	return { 
        success = true,
        items = Core.Classes.Inventory.GetPlayerInventory(source),
        external = {
            type = "drop",
            id = dropData.id,
            name = "Drop",
            items = dropData.items
        }
     }
end

-- Sends drops to everyone
---@param removed table
function Core.Classes.Drops.Beacon (removed)

    -- Payload to send
    local payload = {
        list = Core.Classes.Drops:GetState('Drops')
    }

    -- If removed was passed, send it
    if type(removed) == "table" then
        payload.removed = removed
    end
	
    -- Send new drops data to everyone
    TriggerClientEvent(Config.ClientEventPrefix .. 'UpdateDrops', -1, payload)
end

-- Creates a new drop
---@param dropId string
function Core.Classes.Drops.Get (dropId)
	local drop = false

    for k, d in pairs(Core.Classes.Drops:GetState('Drops')) do
        if d.id == dropId then
            drop = d
        end
    end

    return drop
end

-- Updates a drop
---@param dropId string
---@param data table
function Core.Classes.Drops.Update (dropId, data)
	local drops = Core.Classes.Drops:GetState('Drops')
    local updateKey = false

    for k, d in pairs(Core.Classes.Drops:GetState('Drops')) do
        if d.id == dropId then
            updateKey = k

            for key, val in pairs(data) do
                drops[k][key] = val
            end
        end
    end

    Core.Classes.Drops:UpdateState('Drops', drops)
    Core.Classes.Drops.Beacon()

    -- Return the key updated
    return updateKey
end

-- Removes a drop
---@param dropId string
function Core.Classes.Drops.Remove (dropId)
	local drops = Core.Classes.Drops:GetState('Drops')
    local updateKey = false

    for k, d in pairs(Core.Classes.Drops:GetState('Drops')) do
        if d.id == dropId then
            table.remove(drops, k)
        end
    end

    Core.Classes.Drops:UpdateState('Drops', drops)
    Core.Classes.Drops.Beacon({ dropId })
end

-- Save drop items
---@param dropId string
---@param item table
function Core.Classes.Drops.AddItem (source, dropId, item)
    local drop = Core.Classes.Drops.Get(dropId)

    if not drop then 
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Drops.AddItem",
            message = "Unable to find data for drop: " .. dropId
        })

        return false 
    end

    local items = drop.items
    local newSlot = Core.Classes.Inventory.Utilities.GetFirstEmptySlot(items, Config.Inventories.Drop.MaxSlots)
    
    if not newSlot then 
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Drops.AddItem",
            message = "Unable to determine new empty slot for drop: " .. dropId
        })

        return false 
    end

    item.slot = newSlot.slot
    items[newSlot.key] = item

    if item.name == "money" then
        Framework.Server.RemoveMoney(source, 'cash', item.amount)
    end

    Core.Classes.Drops.SaveItems(dropId, items)
    return true
end

-- Save drop items
---@param dropId string
---@param items table
function Core.Classes.Drops.SaveItems (dropId, items)

	local updatedKey = Core.Classes.Drops.Update(dropId, {
        items = items
    })

    if not updatedKey then return false end
    return Core.Classes.Drops:GetState('Drops')[updatedKey]
end

-- Clears expired drops
function Core.Classes.Drops.ClearExpired ()

    local players = Framework.Server.GetPlayers()

    if Core.Utilities.TableLength(players) == 0 then
        return Core.Utilities.Log({
            title = "Drops.ClearExpired",
            message = "Skipping clear expired drops, no players are online"
        })
    end

    -- Retrieve current drops
    local drops = Core.Classes.Drops:GetState('Drops')
    local removed = {}

    -- Check created time for expiration
    for k, drop in pairs(drops) do
        if drop.expiration < os.time() then
            table.insert(removed, drop.id)
            table.remove(drops, k)
        end
    end

    -- Update state
    Core.Classes.Drops:UpdateState('Drops', drops)
	
    -- Send drops data to everyone
    Core.Classes.Drops.Beacon(removed)
end