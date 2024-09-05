-------------------------------------------------
--- Crafting Setup
-------------------------------------------------

-- Creates the crafting class
Core.Classes.New("Crafting", { props = {}, blips = {}, nearCraftId = false, zones = {} })

-- Loads client shop locations
function Core.Classes.Crafting.Load()
    for craftId, crafting in pairs(Config.Crafting.Locations) do

        -- Group check
        if crafting.group then
            if not Framework.Client.HasGroup(crafting.group) then goto continue end
        end
        
        -- If it provides a prop
        if crafting.prop then

            -- Generate the ped id
            local propId = ("crafting__%s"):format(craftId)

            -- Register the ped in the spawn manager
            Core.SpawnManager.Register('object', {
                id = propId,
                isNetwork = false,
                prop = crafting.prop,
                location = crafting.location,
                target = Config.UseTarget and {
                    options = {
                        {
                            action = function ()
                                Core.Classes.Crafting.Open(craftId)
                            end,
                            icon = "fas fa-eye",
                            label = Core.Language.Locale('craftingTarget')
                        }
                    },
                    distance = crafting.radius or 1.5
                } or false
            })

            local props = Core.Classes.Crafting:GetState("props")
            table.insert(props, propId)
            Core.Classes.Crafting:UpdateState("props", props)
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

        if not Config.UseTarget then
            Core.Classes.Crafting.AddZone(craftId, lib.zones.sphere({
                coords = vector3(crafting.location.x, crafting.location.y, crafting.location.z),
                radius = crafting.radius or 3,
                debug = false,
                onEnter = function ()
                    -- Group check
                    if crafting.group then
                        if not Framework.Client.HasGroup(crafting.group) then return end
                    end
    
                    Core.Classes.Interact.Show(Core.Language.Locale('craftingInteractive', {
                        key = Config.InteractKey.Label
                    }))
                    
                    Core.Classes.Crafting:UpdateState('nearCraftId', craftId)
                end,
                onExit = function ()
                    -- Group check
                    if crafting.group then
                        if not Framework.Client.HasGroup(crafting.group) then return end
                    end
    
                    Core.Classes.Interact.Hide()
                    Core.Classes.Crafting:UpdateState('nearCraftId', false)
                end
            }))
        end

        ::continue::
    end
end

-- Adds new zone
---@param id string
---@param zone CZone
function Core.Classes.Crafting.AddZone(id, zone)
    local zones = Core.Classes.Crafting:GetState('zones')
    if zones[id] then
        if zones[id] ~= nil then
            zones[id]:remove()
        end
    end

    zones[id] = zone
    Core.Classes.Crafting:GetState('zones', zones)
end

-- Removes existing zone
---@param id number
function Core.Classes.Crafting.RemoveZone(id)
    local zones = Core.Classes.Crafting:GetState('zones')

    if zones[id] then
        if zones[id] ~= nil then
            zones[id]:remove()
            zones[id] = nil
            Core.Classes.Crafting:GetState('zones', zones)
        end
    end
end

-- Open shop if near one
---@param data table
function Core.Classes.Crafting.Craft(data)
    local res = lib.callback.await(Config.ServerEventPrefix .. 'CraftItem', false, data)
    Core.Classes.Inventory.Update()
    return res
end

-- Open shop if near one
---@param id string
function Core.Classes.Crafting.Open(id)
    local craftId = Core.Classes.Crafting:GetState('nearCraftId') or id

    if craftId then
        Core.Utilities.Log({
            title = "Crafting.Open()",
            message = "Attempting to open " .. craftId
        })

        TriggerServerEvent(Config.ServerEventPrefix .. 'OpenCrafting', craftId)
    end
end

-- Cleanup props and blips on resourceStop
function Core.Classes.Crafting.Cleanup()
    local blips = Core.Classes.Crafting:GetState("blips")
    for _, blip in pairs(blips) do RemoveBlip(blip) end

    local zones = Core.Classes.Crafting:GetState("zones")
    for id, zone in pairs(zones) do Core.Classes.Crafting.RemoveZone(id) end
end