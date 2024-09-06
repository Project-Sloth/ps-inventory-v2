Core.Classes.New("Weapon")

local UnarmedWeapon = "WEAPON_UNARMED"

-- Initialization for weapons
function Core.Classes.Weapon.Init ()

    -- Set attachments as useable
    for attachmentItem, component in pairs(Config.Weapons.Attachments) do
        Core.Classes.Inventory.CreateUseableItem(attachmentItem, function (source, item)
            Core.Classes.Weapon.EquipAttachment(source, item.name)
        end)
    end

    -- Creates useable ammo boxes
    for take, recieve in pairs (Config.Weapons.AmmoBoxes) do
        Core.Classes.Inventory.CreateUseableItem(take, function(source, item)
            local Player = Framework.Server.GetPlayer(source)
            local check = Framework.Server.HasItem(source, take, 1)
            
            if check then 
                TriggerClientEvent(Config.ClientEventPrefix .. 'UseAmmoBox', source, take, recieve.item)
            end
        end)
    end
end

-- Returns list of weapons (Also includes addons)
---@return table
function Core.Classes.Weapon.List ()
    local list = Config.Weapons.List

    for _, val in pairs(Config.Weapons.AddonWeapons) do
        table.insert(list, val)
    end

    return list
end

-- Returns weapon by hash
---@param weaponHash number
function Core.Classes.Weapon.GetByHash (weaponHash)
    local list = Core.Classes.Weapon.List()

    for _, weapon in pairs(list) do
        if GetHashKey(weapon:upper()) == weaponHash then
            return weapon
        end
    end

    return false
end

-- Sends disarm event to client
---@param src number
function Core.Classes.Weapon.Disarm (src)
    TriggerClientEvent(Config.ClientEventPrefix .. "DisarmWeapon", src)
end

-- Removes weapon attachment from weapon
---@param src number
---@param attachmentData table
---@param weaponState table
function Core.Classes.Weapon.RemoveAttachment (src, attachmentData, weaponState)

    -- Payload validation
    if not attachmentData.slot then 
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Weapon.RemoveAttachment",
            message = "Invalid payload for attachmentData - slot is missing"
        })

        return { success = false } 
    end

    if not attachmentData.attachment then
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Weapon.RemoveAttachment",
            message = "Invalid payload for attachmentData - attachment is missing"
        })
        
        return { success = false } 
    end

    if not attachmentData.component then 
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Weapon.RemoveAttachment",
            message = "Invalid payload for attachmentData - component is missing"
        })

        return { success = false } 
    end

    -- Get player inventory
    local inventory = Core.Classes.Inventory.GetPlayerInventory(src)
    if not inventory then
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Weapon.RemoveAttachment",
            message = "Unable to retrieve player inventory"
        })

        return { success = false } 
    end

    -- Get the slot data
    local slot = Core.Classes.Inventory.Utilities.GetSlotBySlotNumber(inventory, attachmentData.slot)
    if not slot then 
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Weapon.RemoveAttachment",
            message = "Unable to get slot data"
        })

        return { success = false } 
    end

    -- Get the slot key
    local slotKey = Core.Classes.Inventory.Utilities.GetSlotKeyForItemBySlotNumber(inventory, attachmentData.slot)
    if not slotKey then
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Weapon.RemoveAttachment",
            message = "Unable to retrieve slotKey for slot data"
        })

        return false 
    end

    if not slot.info then 
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Weapon.RemoveAttachment",
            message = "Unable to retrieve slot.info - does it exist for this item?"
        })

        return false 
    end

    if not slot.info.attachments then 
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Weapon.RemoveAttachment",
            message = "Unable to retrieve slot.info.attachments for this item"
        })

        return false 
    end

    -- Retrieve the attachment key
    local attachmentKey = false
    for k, attachment in pairs(slot.info.attachments) do
        if attachment.item == attachmentData.attachment then
            attachmentKey = k
        end
    end

    if not attachmentKey then 
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Weapon.RemoveAttachment",
            message = "Unable to find the key for specified attachment"
        })

        return false 
    end

    -- Remove from table
    table.remove(slot.info.attachments, attachmentKey)

    -- Update slot in inventory table
    inventory[slotKey] = slot

    -- Save their inventory
    Core.Classes.Inventory.SavePlayerInventory(src, inventory)

    -- Check if the player is currently holding this weapon
    if weaponState then
        if weaponState.currentWeaponData then
            if weaponState.currentWeaponData.slot == attachmentData.slot then
                local ped = GetPlayerPed(src)

                RemoveWeaponComponentFromPed(
                    ped, 
                    GetHashKey(slot.name:upper()), 
                    GetHashKey(attachmentData.component:upper())
                )
            end
        end
    end

    -- Remove the attachment from their inventory
    Core.Classes.Inventory.AddItem(src, attachmentData.attachment, 1)

    return { success = true }
end

-- Equips or removes an attachment for ped's active weapon
---@param src number
---@param item string
function Core.Classes.Weapon.EquipAttachment (src, attachmentItem)
    local ped = GetPlayerPed(src)

    -- Get the weapon for the ped
    local weaponHash = GetSelectedPedWeapon(ped)
    local weaponName = Core.Classes.Weapon.GetByHash(weaponHash)

    if not weaponName then 
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Weapon.EquipAttachment",
            message = "Unable to retrieve weaponName for " .. weaponHash
        })

        return false 
    end

    if weaponName:upper() == UnarmedWeapon then return false end

    -- Get the attachment component
    local attachmentComponent = Core.Classes.Weapon.TakesAttachment(attachmentItem, weaponName)
    if not attachmentComponent then
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Weapon.EquipAttachment",
            message = "Unable to retrieve attachment component"
        })

        return false 
    end

    -- Get player inventory
    local inventory = Core.Classes.Inventory.GetPlayerInventory(src)
    if not inventory then 
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Weapon.EquipAttachment",
            message = "Unable to retrieve player inventory"
        })

        return false 
    end

    -- Get the weapon slot
    local weaponSlot = Core.Classes.Inventory.Utilities.GetItemFromListByName(inventory, weaponName)
    if not weaponSlot then 
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Weapon.EquipAttachment",
            message = "Unable to retrieve weapon slot"
        })

        return false 
    end

    -- Get the slot key
    local slotKey = Core.Classes.Inventory.Utilities.GetSlotKeyForItemBySlotNumber(inventory, weaponSlot.slot)
    if not slotKey then 
        Core.Utilities.Log({
            type = "error",
            title = "Core.Classes.Weapon.EquipAttachment",
            message = "Unable to retrieve slotKey based on weapon slot data"
        })

        return false 
    end

    -- Check if weapon has attachment
    local hasAttachment = Core.Classes.Weapon.HasAttachment(attachmentComponent.component, weaponSlot)

    -- If it has the attachment, simply return false
    if hasAttachment then return false end

    -- If for some reason the tables needed do not exist
    if not weaponSlot.info then weaponSlot.info = {} end
    if not weaponSlot.info.attachments then weaponSlot.info.attachments = {} end

    -- Attach component to weapon
    table.insert(weaponSlot.info.attachments, {
        item = attachmentComponent.item,
        label = attachmentComponent.label,
        component = attachmentComponent.component:upper()
    })

    -- Give component to player's weapon
    GiveWeaponComponentToPed(ped, weaponHash, attachmentComponent.component)

    -- Update the inventory table
    inventory[slotKey] = weaponSlot
    
    -- Save their inventory
    Core.Classes.Inventory.SavePlayerInventory(src, inventory)

    -- Remove the attachment from their inventory
    Core.Classes.Inventory.RemoveItem(src, attachmentItem, 1)

    return true
end

-- Checks if weapon has an attachment
---@param component string
---@param attachments table
---@return boolean
function Core.Classes.Weapon.HasAttachment (component, weaponData)
    if not weaponData.info then return false end
    if not weaponData.info.attachments then return false end
    if type(weaponData.info.attachments) ~= "table" then return false end

    for key, attachment in pairs(weaponData.info.attachments) do
        if attachment.component == component then
            return true
        end
    end

    return false
end

-- Checks if weapon takes a specific attachment
---@param weaponName string
---@param attachment string
---@return table|boolean
function Core.Classes.Weapon.TakesAttachment (attachment, weaponName)
    if Config.Weapons.Attachments[attachment] and Config.Weapons.Attachments[attachment][weaponName] then
        local itemsList = Core.Classes.Inventory.Items()
        if not itemsList[attachment] then return false end

        return {
            component = Config.Weapons.Attachments[attachment][weaponName],
            item = attachment,
            label = itemsList[attachment].label
        }
    end

    return false
end

-- If durability is ignored for a specific weapon
---@param weaponName string
function Core.Classes.Weapon.IgnoreDurability (weaponName)
    for _, name in pairs(Config.Weapons.NoDurability) do
        if name == weaponName then
            return true
        end
    end
    
    return false
end

-- Gets ammo item based on ammo type
---@param ammoType string
---@return table|boolean
function Core.Classes.Weapon.GetAmmoItem (ammoType)
    local ammoItem = Config.Weapons.AmmoItems[ammoType:upper()]
    if not ammoItem then return false end
    return ammoItem
end

-- Returns if weapon should remove 1 of itself
---@param weaponName string
---@return boolean
function Core.Classes.Weapon.IsRemovable (weaponName)
    return Core.Utilities.TableHasValue(Config.Weapons.Removables, weaponName)
end

-- Updates ammo amount by type
function Core.Classes.Weapon.UpdateAmmo (src, weaponData, amount)
    if amount < 1 then return { success = false } end
    if not weaponData then return { success = false } end

    -- If weapon is a removable, remove from inventory and return early.
    if Core.Classes.Weapon.IsRemovable(weaponData.name) then
        Core.Classes.Inventory.RemoveItem(src, weaponData.name, amount, weaponData.slot, true)
        return { success = true, disarm = true }
    end

    -- If we got this far and there is no ammo type, return false
    if not weaponData.ammotype then return { success = false } end

    -- Get the item for the ammo type
    local item = Core.Classes.Weapon.GetAmmoItem(weaponData.ammotype)
    if not item then return { success = false } end

    -- Make sure the inventory has this ammo item
    local slots = Core.Classes.Inventory.GetSlotsWithItem(src, item, "slots")
    if Core.Utilities.TableLength(slots) == 0 then return { success = false } end
    
    -- Remove the ammount of ammo from the player inventory
    Core.Classes.Inventory.RemoveItem(src, item, amount, nil, true)

    -- Only update quality if not in the NoDurability configuration
    if not Core.Utilities.TableHasValue(Config.Weapons.NoDurability, weaponData.name) then
        Core.Classes.Weapon.UpdateQuality(src, weaponData)
    end

    return { success = true }
end

-- Updates weapon quality
function Core.Classes.Weapon.UpdateQuality (src, weaponData)

    -- Get slot
    local item = Core.Classes.Inventory.GetSlot(src, weaponData.slot)
    if not item then return false end

    local durabilityRate = Config.Weapons.DurabilityRateOverrides[item.name] or 0.15

    -- If for some reason quality isn't in info, add it
    if not item.info.quality then
        item.info.quality = 100
    end

    -- Decrease the quality
    item.info.quality = item.info.quality - durabilityRate

    -- If quality drops below 0, keep it at 0
    if item.info.quality < 0 then
        item.info.quality = 0
    end

    -- Update the item
    Core.Classes.Inventory.UpdateItem(src, item.slot, item)
    return true
end

exports('DisarmWeapon', Core.Classes.Weapon.Disarm)
