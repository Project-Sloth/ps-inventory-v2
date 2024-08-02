-------------------------------------------------
--- Shops Setup
-------------------------------------------------

-- Creates the shops class
Classes.New("Shops", { peds = {}, nearShopId = false })

-------------------------------------------------
--- Loads client shop locations
-------------------------------------------------
function Classes.Shops.Load()
    for _, shop in pairs(Config.Shops) do
        for _, location in pairs(shop.locations) do
            if shop.npc then
                if type(shop.npc) == "table" then

                    local ped = Utilities.CreateNetworkPed(
                        shop.npc.model, 
                        location.x, 
                        location.y, 
                        location.z, 
                        location.w
                    )

                    if ped then
                        if ped.NetworkId then
                            local peds = Classes.Shops:GetState("peds")
                            table.insert(peds, ped.NetworkId)
                            Classes.Shops:UpdateState("peds", peds)

                            if Config.UseTarget then
                                -- Use exports for targets here
                            end
                        end
                    end
                end
            end
        end
    end
end

-------------------------------------------------
--- Dinstance checker for shops
-------------------------------------------------
function Classes.Shops.DistanceCheck()
    local playerPos = GetEntityCoords(PlayerPedId())
    local shortestDistance = math.huge
    local requiredDistance = 4

    for shopId, shop in pairs(Config.Shops) do
        for _, location in pairs(shop.locations) do
            location = vector3(location.x, location.y, location.z)
            local distance = #(playerPos - location)

            if distance < shortestDistance then
                shortestDistance = distance
            end

            if distance <= requiredDistance then
                Classes.Interact.Show('Press [<span class="active-color">' .. Config.InteractKey.Label .. '</span>] to access shop')
                Classes.Shops:UpdateState('nearShopId', shopId)

                while distance <= requiredDistance do
                    Wait(100)
                    playerPos = GetEntityCoords(PlayerPedId())
                    distance = #(playerPos - location)
                end

                Classes.Interact.Hide()
                Classes.Shops:UpdateState('nearShopId', false)
            end
        end
    end

    Wait(100 + math.floor(shortestDistance * 10))
end

-------------------------------------------------
--- Open shop if near one
-------------------------------------------------
function Classes.Shops.Buy(data)
    local res = lib.callback.await(Config.ServerEventPrefix .. 'Buy', false, data)

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
--- Open shop if near one
-------------------------------------------------
function Classes.Shops.Open()
    local shopId = Classes.Shops:GetState('nearShopId')

    if shopId then
        TriggerServerEvent(Config.ServerEventPrefix .. 'OpenShop', shopId)
    end
end

-------------------------------------------------
--- Cleanup network peds on resourceStop
-------------------------------------------------
function Classes.Shops.Cleanup()
    local peds = Classes.Shops:GetState("peds")
    for _, ped in pairs(peds) do Utilities.DeleteEntity(ped) end
end