-------------------------------------------------
--- Crafting Setup
-------------------------------------------------

-- Creates the crafting class
Core.Classes.New("Crafting", { props = {}, blips = {}, nearCraftId = false })

-------------------------------------------------
--- Loads client shop locations
-------------------------------------------------
function Core.Classes.Crafting.Load()
    for _, crafting in pairs(Config.Crafting.Locations) do

        -- Group check
        if crafting.group then
            if not Framework.Client.HasGroup(crafting.group) then goto continue end
        end
        
        -- If it provides a prop
        if crafting.prop then
            local prop = Core.Utilities.CreateObject(crafting.prop, crafting.location)
            if prop then
                local props = Core.Classes.Crafting:GetState("props")
                table.insert(props, prop.EntityId)
                Core.Classes.Crafting:UpdateState("props", props)
            end
        end

        -- If blip has settings
        if crafting.blip then
            if type(crafting.blip) == "table" then
                
                local blips = Core.Classes.Shops:GetState("blips")

                local blip = Core.Utilities.CreateBlip({
                    name = crafting.name,
                    color = crafting.blip.color,
                    scale = crafting.blip.scale,
                    sprite = crafting.blip.sprite
                }, vector3(crafting.location.x, crafting.location.y, crafting.location.z))

                table.insert(blips, blip)
                Core.Classes.Crafting:UpdateState("blips", blips)
            end
        end

        ::continue::
    end
end

-------------------------------------------------
--- Dinstance checker for crafting
-------------------------------------------------
function Core.Classes.Crafting.DistanceCheck()
    local playerPos = GetEntityCoords(PlayerPedId())
    local shortestDistance = math.huge
    local requiredDistance = 3

    for craftId, crafting in pairs(Config.Crafting.Locations) do

        -- Group check
        if crafting.group then
            if not Framework.Client.HasGroup(crafting.group) then goto continue end
        end

        local location = vector3(crafting.location.x, crafting.location.y, crafting.location.z)
        local distance = #(playerPos - location)

        if distance < shortestDistance then
            shortestDistance = distance
        end

        if distance <= (crafting.radius or requiredDistance) then
            Core.Classes.Interact.Show('Press [<span class="active-color">' .. Config.InteractKey.Label .. '</span>] to access crafting')
            Core.Classes.Crafting:UpdateState('nearCraftId', craftId)

            while distance <= (crafting.radius or requiredDistance) do
                Wait(100)
                playerPos = GetEntityCoords(PlayerPedId())
                distance = #(playerPos - location)
            end

            Core.Classes.Interact.Hide()
            Core.Classes.Crafting:UpdateState('nearCraftId', false)
        end

        ::continue::
    end

    Wait(100 + math.floor(shortestDistance * 10))
end

-------------------------------------------------
--- Open shop if near one
-------------------------------------------------
function Core.Classes.Crafting.Craft(data)
    local res = lib.callback.await(Config.ServerEventPrefix .. 'CraftItem', false, data)

    -- Will load new inventory and render inventory
    if res then
        if res.success then
            if res.success == true then
                Core.Classes.Inventory:UpdateState("Items", lib.callback.await(Config.ServerEventPrefix .. 'GetPlayerInventory', false))
                res.items = Core.Classes.Inventory:GetState("Items")
            end
        end
    end

    return res
end

-------------------------------------------------
--- Open shop if near one
-------------------------------------------------
function Core.Classes.Crafting.Open()
    local craftId = Core.Classes.Crafting:GetState('nearCraftId')

    if craftId then
        TriggerServerEvent(Config.ServerEventPrefix .. 'OpenCrafting', craftId)
    end
end

-------------------------------------------------
--- Cleanup props and blips on resourceStop
-------------------------------------------------
function Core.Classes.Crafting.Cleanup()
    local props = Core.Classes.Crafting:GetState("props")
    for _, prop in pairs(props) do Core.Utilities.DeleteEntity(prop, 'object') end

    local blips = Core.Classes.Crafting:GetState("blips")
    for _, blip in pairs(blips) do RemoveBlip(blip) end
end