-------------------------------------------------
--- Crafting Setup (Runs when server starts)
-------------------------------------------------

-- Creates the crafting class
Core.Classes.New("Crafting", { Queue = {} })

-------------------------------------------------
--- Builds item list from crafting item list
-------------------------------------------------
function Core.Classes.Crafting.BuildItemList(recipes)
    local itemList = {}

    for _, recipe in pairs(recipes) do
        if not Config.Crafting.Recipes[recipe] then goto continue end

        for _, item in pairs(Config.Crafting.Recipes[recipe]) do
            local itemData = Core.Classes.Inventory:GetState("Items")[item.item]
            if itemData then
                itemData.slot = tonumber(Core.Utilities.TableLength(itemList)) + 1
                itemData.crafting = item
                table.insert(itemList, itemData)
            end
        end

        ::continue::
    end

    return itemList
end

-------------------------------------------------
--- Open Crafting via Placeable Item
-------------------------------------------------
function Core.Classes.Crafting.OpenByPlaceable (src, item)
    local Player = Framework.Server.GetPlayer(src)
    local crafting = Config.Crafting.Placeables[item]

    if not crafting then
        return Core.Utilities.Log({
            type = "error",
            title = "OpenByPlaceable",
            message = "Crafting.Placeables[" .. item .. "] does not exist"
        })
    end

    local items = Core.Classes.Crafting.BuildItemList(crafting.recipes)

    Core.Classes.Inventory.OpenInventory(src, {
        type = "crafting",
        id = 'placeable-' .. item,
        name = 'Crafting Bench',
        slots = #items,
        items = items
    })
end

-------------------------------------------------
--- open Crafting Bench
-------------------------------------------------
function Core.Classes.Crafting.Open (src, craftId)
    local Player = Framework.Server.GetPlayer(src)
    local crafting = Config.Crafting.Locations[craftId]

    if not crafting then
        return Core.Utilities.Log({
            type = "error",
            title = "OpenCrafting",
            message = "Crafting.Locations[" .. craftId .. "] does not exist"
        })
    end

    local items = Core.Classes.Crafting.BuildItemList(crafting.recipes)

    Core.Classes.Inventory.OpenInventory(src, {
        type = "crafting",
        id = craftId,
        name = crafting.name,
        slots = #items,
        items = items
    })
end

-------------------------------------------------
--- Processes queue items
-------------------------------------------------
function Core.Classes.Crafting.ProcessQueue ()
    local queue = Core.Classes.Crafting:GetState('Queue')

    for source, items in pairs(queue) do
        if type(items) == "table" then
            if table.type(items) ~= "empty" then
                for queueId, itemData in pairs(items) do
                    if itemData ~= nil then
                        if itemData.completion < os.time() then
                            Core.Classes.Inventory.AddItem(source, itemData.item.name, itemData.amount)
                            TriggerClientEvent(Config.ClientEventPrefix .. "RemoveCraftingQueueItem", source, queueId)
                            queue[source][queueId] = nil
                        end
                    end
                end
            end
        end
    end

    Core.Classes.Crafting.UpdateQueue(queue)
end

-------------------------------------------------
--- Updates queue state
-------------------------------------------------
function Core.Classes.Crafting.UpdateQueue (queue)
    Core.Classes.Crafting:UpdateState('Queue', queue)
end

-------------------------------------------------
--- Gets full queue for player
-------------------------------------------------
function Core.Classes.Crafting.GetQueueForPlayer (source)
    local queue = Core.Classes.Crafting:GetState('Queue')
    local playerQueue = queue[source]
    if not playerQueue then return false end

    if not Framework.Server.GetPlayer(source) then
        queue[source] = nil
        Core.Classes.Crafting.UpdateQueue(queue)
        return false
    end

    return queue[source]
end

-------------------------------------------------
--- Queues crafting item
-------------------------------------------------
function Core.Classes.Crafting.QueueItem (source, data)
    local queue = Core.Classes.Crafting:GetState('Queue')
    if not queue[source] then queue[source] = {} end
    local queueId = Core.Utilities.GenerateQueueId()
    data.completion = data.item.crafting.time + os.time()
    queue[source][queueId] = data
    Core.Classes.Crafting.UpdateQueue(queue)

    for item, amount in pairs(data.materialsToRemove) do
        Core.Classes.Inventory.RemoveItem(source, item, amount)
    end

    TriggerClientEvent(Config.ClientEventPrefix .. "AddCraftingQueueItem", source, {
        amount = data.amount,
        queueId = queueId,
        item = data.item
    })

    return { success = true }
end

-------------------------------------------------
--- Removes queued item (todo: re-add items to inv)
-------------------------------------------------
function Core.Classes.Crafting.CancelItem (source, queueId)
    local queue = Core.Classes.Crafting:GetState('Queue')
    if not queue[source] then return false end
    if not queue[source][queueId] then return false end
    queue[source][queueId] = nil
    Core.Classes.Crafting.UpdateQueue(queue)
    TriggerClientEvent(Config.ClientEventPrefix .. "RemoveCraftingQueueItem", source, queueId)
end

-------------------------------------------------
--- Check if player can craft item
-------------------------------------------------
function Core.Classes.Crafting.CanCraftItem (source, data)

    -- Validate player
    local src = source
    local Player = Framework.Server.GetPlayer(src)
    if not data.crafting then return false end

    -- Return all categories
    local recipeCategories = {}
    for category, recipeCats in pairs(Config.Crafting.Recipes) do
        table.insert(recipeCategories, category)
    end

    -- Get craftable items from config
    local items = Core.Classes.Crafting.BuildItemList(recipeCategories)

    -- Verify the item by name and slot
    local itemToCraft = false
    for k, item in pairs(items) do
        if item.name == data.itemData.item.name then
            itemToCraft = item
        end
    end

    -- Get player inventory
    if not itemToCraft then return false end
    local inventory = Core.Classes.Inventory.GetPlayerInventory(src)

    -- Iterate materials and check against player inventory
    local materials = {}
    local materialsToRemove = {}
    for _, item in pairs(itemToCraft.crafting.materials) do
        materials[item.item] = false
        materialsToRemove[item.item] = (tonumber(item.amount) * tonumber(data.amount))

        for _, playerItem in pairs(inventory) do
            if playerItem.name == item.item and playerItem.amount >= (tonumber(item.amount) * tonumber(data.amount)) then
                materials[item.item] = true
            end
        end
    end

    -- Make sure all materials are accounted for
    local canCraft = true
    for materialName, material in pairs(materials) do
        if not material then
            canCraft = false
        end
    end

    -- If item is missing a material
    if not canCraft then return false end

    return {
        amount = data.amount,
        item = itemToCraft,
        materials = materials,
        materialsToRemove = materialsToRemove
    }
end

exports("OpenCrafting", Core.Classes.Crafting.Open)