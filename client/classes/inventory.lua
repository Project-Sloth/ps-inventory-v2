-------------------------------------------------
--- Inventory Setup (Runs when server starts)
-------------------------------------------------

-- Creates the inventory class
Classes.New("Inventory", { Loaded = false, Items = {}, IsOpen = false, External = false })

-------------------------------------------------
--- Inventory events
-------------------------------------------------
Classes.Inventory.Events = {

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

-------------------------------------------------
--- Load Inventory Items
-------------------------------------------------
function Classes.Inventory.Load(cb)
    local inventory = lib.callback.await(Config.ServerEventPrefix .. 'GetPlayerInventory', false)
    Classes.Inventory:UpdateState("Items", inventory)

    Utilities.Log({
        title = "Inventory Loaded",
        message = Utilities.TableLength(inventory) .. " items were loaded"
    })

    Classes.Inventory:UpdateState('Loaded', true)

    if type(cb) == "function" then
        return cb(Classes.Inventory:GetState("Items"))
    end
end

-------------------------------------------------
--- Update external inventory state
-------------------------------------------------
function Classes.Inventory.UpdateExternalState(external, cb)
    Classes.Inventory:UpdateState("External", external)

    if type(cb) == "function" then
        return cb(Classes.Inventory:GetState("External"))
    end
end

-------------------------------------------------
--- Drop item
-------------------------------------------------
function Classes.Inventory.Drop(data)
    local res = lib.callback.await(Config.ServerEventPrefix .. 'Drop', false, data)
    return res
end

-------------------------------------------------
--- Move item
-------------------------------------------------
function Classes.Inventory.Move(data)
    local res = lib.callback.await(Config.ServerEventPrefix .. 'Move', false, data)

    -- Will load new inventory and render inventory
    if res then
        if res.success then
            if res.success == true then
                Classes.Inventory:UpdateState("Items", lib.callback.await(Config.ServerEventPrefix .. 'GetPlayerInventory', false))
                res.items = Classes.Inventory:GetState("Items")
            end
        end
    end

    return res
end

-------------------------------------------------
--- Can Open Inventory
-------------------------------------------------
function Classes.Inventory.CanOpen(data)
    if not Framework.Client.CanOpenInventory() then return false end
    if LocalPlayer.state.inventoryBusy == true then return false end
    return true
end

-------------------------------------------------
--- Open Inventory
-------------------------------------------------
function Classes.Inventory.Open(data)

    -- Check if can open inventory
    if not Classes.Inventory.CanOpen() then return false end

    Classes.Inventory.Load(function (inventory)
        if not data.external then data.external = nil end
        SendNUIMessage({ action = "open", items = inventory, external = data.external })
        SetNuiFocus(true, true)
        Classes.Inventory:UpdateState('IsOpen', true)

        -- If external is passed
        if data.external then
            Classes.Inventory:UpdateState('External', data.external)
        end
        
        Utilities.Log({
            title = "Inventory Event",
            message = "Inventory was opened"
        })

        Classes.Inventory.Events.OnOpen()
    end)
end

exports('OpenInventory', Classes.Inventory.Open)

-------------------------------------------------
--- Close Inventory
-------------------------------------------------
function Classes.Inventory.Close()
    SendNUIMessage({ action = "close" })
    SetNuiFocus(false, false)
    Classes.Inventory:UpdateState('IsOpen', false)
    Classes.Inventory:UpdateState('External', false)

    Utilities.Log({
        title = "Inventory Event",
        message = "Inventory was closed"
    })

    Classes.Inventory.Events.OnClose()
end

exports('CloseInventory', Classes.Inventory.Close)