-------------------------------------------------
--- Drops Setup (Runs when server starts)
-------------------------------------------------

-- Creates the drop class
Classes.New("Drops", { Drops = {} })

-------------------------------------------------
--- Creates a new drop
-------------------------------------------------
function Classes.Drops.Create (source, data)

    -- Log initiation
    Utilities.Log({
        title = "Drops.Create",
        message = "Creation of drop was initiated"
    })

    -- Validate item
    local inventory = Classes.Inventory.GetPlayerInventory(source)
    local itemData = Classes.Inventory.Utilities.GetItemFromListByName(inventory, data.item.name, data.item.slot) or false
    if not itemData then return { success = false } end

    -- Set item to be sent to drop
    local dropItem = itemData
    dropItem.slot = 1

    -- Generate drop id
    local newDropId = Utilities.GenerateDropId()
    Utilities.Log({
        title = "Drops.Create",
        message = "Generated drop id: " .. newDropId
    })

    -- Validate ped exists
    local ped = GetPlayerPed(source)
    if not DoesEntityExist(ped) then return { success = false } end

    -- Get player coords
    local playerCoords = GetEntityCoords(ped)

    -- Retrieve current drops
    local drops = Classes.Drops:GetState('Drops')

    -- Create new drop
    table.insert(drops, {
        id = newDropId,
        location = playerCoords,
        created = os.time(),
        expiration = (Config.Drops.ExpirationTime) + os.time(),
        items = { dropItem }
    })

    -- Update state
    Classes.Drops:UpdateState('Drops', drops)

    -- Verify it was created
    local dropData = Classes.Drops.Get(newDropId)
    if not dropData then
        Utilities.Log({
            title = "Drops.Create",
            message = "Could not find drop data"
        })
        return { success = false }
    end

    -- Remove from player
    Classes.Inventory.RemoveItem(source, data.item.name, itemData.amount, data.item.slot)

    -- Send drops data to everyone
    Classes.Drops.SendDropsBeacon()

    -- Return new drop data
	return { 
        success = true,
        items = Classes.Inventory.GetPlayerInventory(source),
        external = {
            type = "drop",
            id = dropData.id,
            name = "Drop",
            items = dropData.items
        }
     }
end

-------------------------------------------------
--- Sends drops to everyone
-------------------------------------------------
function Classes.Drops.SendDropsBeacon (removed)

    -- Payload to send
    local payload = {
        list = Classes.Drops:GetState('Drops')
    }

    -- If removed was passed, send it
    if type(removed) == "table" then
        payload.removed = removed
    end
	
    -- Send new drops data to everyone
    TriggerClientEvent(Config.ClientEventPrefix .. 'UpdateDrops', -1, payload)

    -- Log the action
    Utilities.Log({
        title = "Drops.Beacon",
        message = "Sent the following drops data to all clients"
    })

    print(json.encode(payload))
end

-------------------------------------------------
--- Creates a new drop
-------------------------------------------------
function Classes.Drops.Get (dropId)
	local drop = false

    for k, d in pairs(Classes.Drops:GetState('Drops')) do
        if d.id == dropId then
            drop = d
        end
    end

    return drop
end

-------------------------------------------------
--- Updates a drop
-------------------------------------------------
function Classes.Drops.Update (dropId, data)
	local drops = Classes.Drops:GetState('Drops')
    local updateKey = false

    for k, d in pairs(Classes.Drops:GetState('Drops')) do
        if d.id == dropId then
            updateKey = k

            for key, val in pairs(data) do
                print('Update key: ' .. key .. ' for drop ' .. d.id)
                drops[k][key] = val
            end
        end
    end

    Classes.Drops:UpdateState('Drops', drops)
    Classes.Drops.SendDropsBeacon()

    -- Return the key updated
    return updateKey
end

-------------------------------------------------
--- Removes a drop
-------------------------------------------------
function Classes.Drops.Remove (dropId)
	local drops = Classes.Drops:GetState('Drops')
    local updateKey = false

    for k, d in pairs(Classes.Drops:GetState('Drops')) do
        if d.id == dropId then
            table.remove(drops, k)
        end
    end

    Classes.Drops:UpdateState('Drops', drops)
    Classes.Drops.SendDropsBeacon({ dropId })
end

-------------------------------------------------
--- Save drop items
-------------------------------------------------
function Classes.Drops.SaveItems (dropId, items)

	local updatedKey = Classes.Drops.Update(dropId, {
        items = items
    })

    if not updatedKey then return false end
    return Classes.Drops:GetState('Drops')[updatedKey]
end

-------------------------------------------------
--- Clears expired drops
-------------------------------------------------
function Classes.Drops.ClearExpired ()

    local players = Framework.Server.GetPlayers()

    if Utilities.TableLength(players) == 0 then
        return Utilities.Log({
            title = "Drops.ClearExpired",
            message = "Skipping clear expired drops, no players are online"
        })
    end

    -- Retrieve current drops
    local drops = Classes.Drops:GetState('Drops')
    local removed = {}

    -- Check created time for expiration
    for k, drop in pairs(drops) do
        if drop.expiration < os.time() then
            table.insert(removed, drop.id)
            table.remove(drops, k)
        end
    end

    -- Update state
    Classes.Drops:UpdateState('Drops', drops)
	
    -- Send drops data to everyone
    Classes.Drops.SendDropsBeacon(removed)
end