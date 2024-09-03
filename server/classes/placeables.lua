Core.Classes.New("Placeables", { Items = {} })

-- Retrieve placeable items
function Core.Classes.Placeables.All()
    local items = {}
    local query = 'SELECT * FROM inventory_placeables'
	local res = MySQL.query.await(query)
	if not res then return {} end

    for _, item in pairs(res) do
        items[item.id] = item.item and json.decode(item.item) or nil
    end

    return items
end

-- Save new item
---@param item table
function Core.Classes.Placeables.Save(item)
    if not item then 
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Placeables.Save",
            message = "Invalid payload passed for item"
        })

        return false 
    end

    local query = 'INSERT INTO inventory_placeables(item) VALUES(?)'
	local res = MySQL.insert.await(query, { json.encode(item) })

	if not res then
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Placeables.Save",
            message = "An error occurred during the insert execution"
        })

        return false 
    end

    return Core.Classes.Placeables.Beacon()
end

-- Delete existing item
---@param id number
function Core.Classes.Placeables.Delete(id)
    local query = 'DELETE FROM inventory_placeables WHERE id = ?'
	local res = MySQL.query.await(query, { id })

	if not res then 
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Placeables.Delete",
            message = "An error occurred during the delete execution"
        })

        return false 
    end
    
    return Core.Classes.Placeables.Beacon()
end

-- Sends placeables to everyone
function Core.Classes.Placeables.Beacon ()
    local items = Core.Classes.Placeables.All()
    TriggerClientEvent(Config.ClientEventPrefix .. 'UpdatePlaceables', -1, items)
    return true
end

function Core.Classes.Placeables.Place (source, item)
    if not item then 
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Placeables.Place",
            message = "Invalid payload passed for item"
        })

        return false 
    end
    TriggerClientEvent(Config.ClientEventPrefix .. 'PlaceItem', source, item)
end