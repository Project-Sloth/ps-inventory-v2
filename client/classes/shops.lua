-------------------------------------------------
--- Shops Setup
-------------------------------------------------

-- Creates the shops class
Core.Classes.New("Shops", { peds = {}, blips = {}, nearShopId = false })

-------------------------------------------------
--- Loads client shop locations
-------------------------------------------------
function Core.Classes.Shops.Load()
    print("Loading shops")
    for shopId, shop in pairs(Config.Shops) do

        -- Group check
        if shop.group then
            if not Framework.Client.HasGroup(shop.group) then goto continue end
        end
        
        for _, location in pairs(shop.locations) do
            if shop.npc then
                if type(shop.npc) == "table" then

                    local ped = Core.Utilities.CreateNetworkPed(
                        shop.npc.model, 
                        location.x, 
                        location.y, 
                        (location.z - 1), 
                        location.w,
                        shop.npc.scenario
                    )

                    if ped then
                        if ped.EntityId then
                            local peds = Core.Classes.Shops:GetState("peds")
                            table.insert(peds, ped.EntityId)
                            Core.Classes.Shops:UpdateState("peds", peds)

                            if Config.UseTarget then
                                Framework.Client.AddTargetEntity(ped.EntityId, {
                                    options = {
                                        {
                                            action = function ()
                                                TriggerServerEvent(Config.ServerEventPrefix .. 'OpenShop', shopId)
                                            end,
                                            icon = "fas fa-hshopping-basket",
                                            label = shop.name
                                        }
                                    },
                                    distance = 1.5
                                })
                            end
                        end
                    end
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
        end

        ::continue::
    end
end

-------------------------------------------------
--- Dinstance checker for shops
-------------------------------------------------
function Core.Classes.Shops.DistanceCheck()
    local playerPos = GetEntityCoords(PlayerPedId())
    local shortestDistance = math.huge
    local requiredDistance = 3

    for shopId, shop in pairs(Config.Shops) do

        -- Group check
        if shop.group then
            if not Framework.Client.HasGroup(shop.group) then goto continue end
        end

        for _, location in pairs(shop.locations) do
            location = vector3(location.x, location.y, location.z)
            local distance = #(playerPos - location)

            if distance < shortestDistance then
                shortestDistance = distance
            end

            if distance <= (shop.radius or requiredDistance) then
                Core.Classes.Interact.Show('Press [<span class="active-color">' .. Config.InteractKey.Label .. '</span>] to access shop')
                Core.Classes.Shops:UpdateState('nearShopId', shopId)

                while distance <= (shop.radius or requiredDistance) do
                    Wait(100)
                    playerPos = GetEntityCoords(PlayerPedId())
                    distance = #(playerPos - location)
                end

                Core.Classes.Interact.Hide()
                Core.Classes.Shops:UpdateState('nearShopId', false)
            end
        end

        ::continue::
    end

    Wait(100 + math.floor(shortestDistance * 10))
end

-------------------------------------------------
--- Open shop if near one
-------------------------------------------------
function Core.Classes.Shops.Buy(data)
    local res = lib.callback.await(Config.ServerEventPrefix .. 'Buy', false, data)
    Core.Classes.Inventory.Update()
    return res
end

-------------------------------------------------
--- Open shop if near one
-------------------------------------------------
function Core.Classes.Shops.Open()
    local shopId = Core.Classes.Shops:GetState('nearShopId')

    if shopId then
        TriggerServerEvent(Config.ServerEventPrefix .. 'OpenShop', shopId)
    end
end

-------------------------------------------------
--- Cleanup peds and blips on resourceStop
-------------------------------------------------
function Core.Classes.Shops.Cleanup()
    local peds = Core.Classes.Shops:GetState("peds")
    for _, ped in pairs(peds) do
        Core.Utilities.DeleteEntity(ped)

        if Config.UseTarget then
            Framework.Client.RemoveTargetEntity(ped)
        end
    end

    local blips = Core.Classes.Shops:GetState("blips")
    for _, blip in pairs(blips) do RemoveBlip(blip) end
end