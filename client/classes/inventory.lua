-------------------------------------------------
--- Inventory Setup (Runs when server starts)
-------------------------------------------------

-- Creates the inventory class
Core.Classes.New("Inventory", { Loaded = false, Items = {}, IsOpen = false, External = false })

-- Inventory events
Core.Classes.Inventory.Events = {

    OnOpen = function ()
        lib.callback.await(Config.ServerEventPrefix .. 'Event', false, {
            event = "open"
        })
    end,

    OnClose = function ()
        lib.callback.await(Config.ServerEventPrefix .. 'Event', false, {
            event = "close"
        })
    end
}

-- Load Inventory Items
---@param cb? function
function Core.Classes.Inventory.Load(cb)
    local inventory = lib.callback.await(Config.ServerEventPrefix .. 'GetPlayerInventory', false)
    Core.Classes.Inventory:UpdateState("Items", inventory)

    Core.Utilities.Log({
        title = "Inventory Loaded",
        message = Core.Utilities.TableLength(inventory) .. " items were loaded"
    })

    -- Set loaded
    Core.Classes.Inventory:UpdateState('Loaded', true)

    -- Send items in callback if applicable
    if type(cb) == "function" then
        return cb(Core.Classes.Inventory:GetState("Items"))
    end
end

-- Update inventory
function Core.Classes.Inventory.Update()
    Core.Classes.Inventory:UpdateState("Items", lib.callback.await(Config.ServerEventPrefix .. 'GetPlayerInventory', false))
    local items = Core.Classes.Inventory:GetState("Items")
    SendNUIMessage({ action = "update", items = items })
end

-- Update external inventory state
---@param external? table
---@param cb? function
function Core.Classes.Inventory.UpdateExternalState(external, cb)
    Core.Classes.Inventory:UpdateState("External", external)

    if type(cb) == "function" then
        return cb(Core.Classes.Inventory:GetState("External"))
    end
end

-- Give item
---@param data table
function Core.Classes.Inventory.Give(data)
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local targetPlayerId, targetPlayerPed, targetPlayerCoords = lib.getClosestPlayer(pos, 1.5, false)
    data.playerId = targetPlayerId and GetPlayerServerId(targetPlayerId) or nil
    local res = lib.callback.await(Config.ServerEventPrefix .. 'Give', false, data)
    Core.Classes.Inventory.Update()
    return res
end

-- Drop item
---@param data table
function Core.Classes.Inventory.Drop(data)
    data.dropId = Core.Classes.Drops:GetState('nearDropId')
    local res = lib.callback.await(Config.ServerEventPrefix .. 'Drop', false, data)
    Core.Classes.Inventory.Update()
    return res
end

-- Move item
---@param data table
function Core.Classes.Inventory.Move(data)
    local res = lib.callback.await(Config.ServerEventPrefix .. 'Move', false, data)
    Core.Classes.Inventory.Update()
    return res
end

-- Can Open Inventory
function Core.Classes.Inventory.CanOpen()
    if not Framework.Client.CanOpenInventory() then return false end
    if LocalPlayer.state.inventoryBusy == true then return false end
    return true
end

-- Open Inventory
---@param data? table
function Core.Classes.Inventory.Open(data)

    -- Check if can open inventory
    if not Core.Classes.Inventory.CanOpen() then return false end

    Core.Classes.Inventory.Load(function (inventory)
        if not data.external then data.external = nil end
        SendNUIMessage({ action = "open", items = inventory, external = data.external })
        SetNuiFocus(true, true)
        Core.Classes.Inventory:UpdateState('IsOpen', true)

        -- If external is passed
        if data.external then
            Core.Classes.Inventory:UpdateState('External', data.external)
        end
        
        Core.Utilities.Log({
            title = "Inventory Event",
            message = "Inventory was opened"
        })

        Core.Classes.Inventory.Events.OnOpen()
    end)
end

-- Close Inventory
function Core.Classes.Inventory.Close()
    SendNUIMessage({ action = "close" })
    SetNuiFocus(false, false)
    Core.Classes.Inventory:UpdateState('IsOpen', false)
    Core.Classes.Inventory:UpdateState('External', false)

    Core.Utilities.Log({
        title = "Inventory Event",
        message = "Inventory was closed"
    })

    Core.Classes.Inventory.Events.OnClose()
end

exports('OpenInventory', Core.Classes.Inventory.Open)
exports('CloseInventory', Core.Classes.Inventory.Close)