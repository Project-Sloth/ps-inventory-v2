-------------------------------------------------
--- Shops Setup
-------------------------------------------------

-- Creates the shops class
Core.Classes.New("Shops", { peds = {}, blips = {}, nearShopId = false, zones = {} })

-- Loads client shop locations
function Core.Classes.Shops.Load()
    for shopId, shop in pairs(Config.Shops) do

        -- Group check
        if shop.group then
            if not Framework.Client.HasGroup(shop.group) then goto continue end
        end
        
        for locationKey, location in pairs(shop.locations) do
            if shop.npc then
                if type(shop.npc) == "table" then

                    -- Generate the ped id
                    local pedId = ("%s_%s_%s"):format(shopId, "ped", locationKey)

                    -- Register the ped in the spawn manager
                    Core.SpawnManager.Register('ped', {
                        id = pedId,
                        isNetwork = false,
                        modelHash = shop.npc.model,
                        location = location,
                        heading = location.w,
                        scenario = shop.npc.scenario,
                        target = Config.UseTarget and {
                            options = {
                                {
                                    action = function ()
                                        TriggerServerEvent(Config.ServerEventPrefix .. 'OpenShop', shopId)
                                    end,
                                    icon = "fas fa-shopping-basket",
                                    label = Core.Language.Locale('shopTarget', {
                                        shopName = shop.name
                                    })
                                }
                            },
                            distance = shop.radius or 1.5
                        } or false
                    })

                    -- Update shop peds state
                    local peds = Core.Classes.Shops:GetState("peds")
                    table.insert(peds, pedId)
                    Core.Classes.Shops:UpdateState("peds", peds)
                end
            end

            if shop.blip then
                if type(shop.blip) == "table" then
                    local blips = Core.Classes.Shops:GetState("blips")

                    local blip = Core.Utilities.CreateBlip({
                        name = shop.name,
                        color = shop.blip.color,
                        scale = shop.blip.scale,
                        sprite = shop.blip.sprite
                    }, vector3(location.x, location.y, location.z))

                    table.insert(blips, blip)
                    Core.Classes.Shops:UpdateState("blips", blips)
                end
            end

            if not Config.UseTarget then
                Core.Classes.Shops.AddZone(shopId .. "_" .. locationKey, lib.zones.sphere({
                    coords = vector3(location.x, location.y, location.z),
                    radius = shop.radius or 3,
                    debug = false,
                    onEnter = function ()
                        -- Group check
                        if shop.group then
                            if not Framework.Client.HasGroup(shop.group) then return end
                        end
        
                        Core.Classes.Interact.Show(Core.Language.Locale('shopInteractive', {
                            key = Config.InteractKey.Label
                        }))

                        Core.Classes.Shops:UpdateState('nearShopId', shopId)
                    end,
                    onExit = function ()
                        Core.Classes.Interact.Hide()
                        Core.Classes.Shops:UpdateState('nearShopId', false)
                    end
                }))
            end
        end

        ::continue::
    end
end

-- Adds new zone
---@param id string
---@param zone CZone
function Core.Classes.Shops.AddZone(id, zone)
    local zones = Core.Classes.Shops:GetState('zones')

    if zones[id] then
        if zones[id] ~= nil then
            zones[id]:remove()
        end
    end

    zones[id] = zone
    Core.Classes.Shops:GetState('zones', zones)
end

-- Removes existing zone
---@param id string
function Core.Classes.Shops.RemoveZone(id)
    local zones = Core.Classes.Shops:GetState('zones')

    if zones[id] then
        if zones[id] ~= nil then
            zones[id]:remove()
            zones[id] = nil
        end
    end

    Core.Classes.Shops:GetState('zones', zones)
end

-- Open shop if near one
---@param data table
function Core.Classes.Shops.Buy(data)
    local res = lib.callback.await(Config.ServerEventPrefix .. 'Buy', false, data)
    Core.Classes.Inventory.Update()
    return res
end

-- Open shop if near one
function Core.Classes.Shops.Open()
    local shopId = Core.Classes.Shops:GetState('nearShopId')

    if shopId then
        Core.Utilities.Log({
            title = "Shops.Open()",
            message = "Attempting to open " .. shopId
        })

        TriggerServerEvent(Config.ServerEventPrefix .. 'OpenShop', shopId)
    end
end

-- Cleanup peds and blips on resourceStop
function Core.Classes.Shops.Cleanup()
    local blips = Core.Classes.Shops:GetState("blips")
    for _, blip in pairs(blips) do RemoveBlip(blip) end

    local zones = Core.Classes.Shops:GetState("zones")
    for id, zone in pairs(zones) do Core.Classes.Shops.RemoveZone(id) end
end