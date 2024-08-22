-- Give Item Command
lib.addCommand('giveitem', {
    help = 'Gives player an item',
    params = {{
        name = 'target',
        type = 'playerId',
        help = 'Target player\'s server id'
    }, {
        name = 'item',
        type = 'string',
        help = 'Item name'
    }, {
        name = 'amount',
        type = 'number',
        help = 'Amount of item'
    }},
    restricted = Config.CommandPermissions.GiveItem
}, function(source, args, raw)

    local PlayerIdentity = Framework.Server.GetPlayerIdentity(args.target)
    local itemData = Core.Classes.Inventory:GetState("Items")[args.item:lower()]

    -- Validate that player identity is available
    if PlayerIdentity then

        -- Validate item
        if itemData then
            -- check iteminfo
            local info = {}

            -- If id card, format data
            if itemData["name"] == "id_card" then
                info.citizenid = PlayerIdentity.identifier
                info.firstname = PlayerIdentity.firstname
                info.lastname = PlayerIdentity.lastname
                info.birthdate = PlayerIdentity.birthdate
                info.gender = PlayerIdentity.gender

            -- If driver license, format data
            elseif itemData["name"] == "driver_license" then
                info.firstname = PlayerIdentity.firstname
                info.lastname = PlayerIdentity.lastname
                info.birthdate = PlayerIdentity.birthdate
                info.type = "Class C Driver License"

            -- If weapon, set amount to 1 automatically and generate serial number
            elseif itemData["type"] == "weapon" then
                args.amount = 1
                info.serie = Core.Utilities.GenerateSerialNumber()
                info.quality = 100

            -- If harness, set uses to 20
            elseif itemData["name"] == "harness" then
                info.uses = 20

            -- Handle the worth of marked bills
            elseif itemData["name"] == "markedbills" then
                info.worth = math.random(5000, 10000)

            -- Set random lab to lab key
            elseif itemData["name"] == "labkey" then
                info.lab = exports["qb-methlab"]:GenerateRandomLab()

            -- Set default url for printed document
            elseif itemData["name"] == "printerdocument" then
                info.url = ""

            -- If decay is enabled for item, set quality
            elseif itemData.decay and itemData.decay > 0 then
                info.quality = 100
            end

            if Core.Classes.Inventory.AddItem(args.target, itemData.name, args.amount, false, info) then
                Core.Utilities.Log({
                    type = "success",
                    title = "GiveItem",
                    message = itemData.name .. "[x" .. args.amount .. "] was given to " .. PlayerIdentity.name .. " by admin"
                })

                if itemData.name == "money" then
                    Framework.Server.AddMoney(args.target, "cash", args.amount)
                end

                return true
            else
                return Core.Utilities.Log({
                    type = "error",
                    title = "GiveItem",
                    message = itemData.name .. "[x" .. args.amount .. "] could not be given to " .. PlayerIdentity.name
                })
            end
        else
            return Core.Utilities.Log({
                type = "error",
                title = "GiveItem",
                message = args.item .. "[x" .. args.amount .. "] could not be given to " .. PlayerIdentity.name .. " - Item does not exist"
            })
        end
    else
        return Core.Utilities.Log({
            type = "error",
            title = "GiveItem",
            message = args.item .. "[x" .. args.amount .. "] could not be given to player: " .. args.target .. " - Player not online"
        })
    end
end)
