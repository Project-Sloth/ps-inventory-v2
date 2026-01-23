# Project Sloth Inventory V2

Version 2 of Project Sloth's slot based inventory for FiveM. This version is built to work with newer versions of QB Core. While there is an option for backwards compatibility, please note it is not heavily tested and may not work as intended.

*NOTE: For all support questions, ask in our [Discord](https://www.discord.gg/projectsloth) support chat. Do not create issues if you need help. Issues are for bug reporting and new features only.*

### Frameworks Supported
- [QBCore](https://github.com/qbcore-framework)
- [QBOX](https://github.com/Qbox-project) - Coming soon
### Features
- Slot based inventory
- Stash system
- Store system
- View player inventories (Robbing, administration, police)
- Crafting System (Both locations and placeable items)
- Give items to closest player
- Drop system
- Trunk system (Configurable by class and model)
- Glovebox system (Configurable by class and model)
- Targetting support for qb-target and ox_target
- Interactive UI when targetting is not available
- Decay system
- Hotbar (With toggling capability)
- Configurable themes
- Multi-language support
- Vending Machines
- Cash as an item
- Weapons system (replaces qb-weapons)

![Screenshot 2024-09-01 075501](https://github.com/user-attachments/assets/4ae21d3c-7879-4a04-92b6-f6dd323d89ae)
![Screenshot 2024-09-01 075618](https://github.com/user-attachments/assets/f6ff5107-5502-47a9-94c9-18cc3b347ec1)
![Screenshot 2024-09-01 075650](https://github.com/user-attachments/assets/c6b53f27-35e1-4b27-ae6f-032345f5704a)

### Dependencies

- `oxmysql`
- `ox_lib`
- `qb-core`

### Installation

- Download the resource from the repo
- Drop the resource into your qb server resources
- Rename to `ps-inventory`
- Run `__install/database.sql` in your database
- Start resource in server.cfg after qb-core or esx core (If using targetting, make sure qb-target or ox_target is started before)
- Delete and remove `qb-inventory`
- Delete and remove `qb-shops`
- Delete and remove `qb-weapons`
- Replace all `exports['qb-inventory']` for `exports['ps-inventory']`
- Restart server

### Old QB Core Conversion:

- To use with old QB Core versions, please use the following variables in `config/config.lua`

```
-- Framework
Framework = "qb", -- "qb"

-- QB specific
OldCore = true, -- If you are using an older version of QB Core
ConvertInventories = true, -- Convert old QB core inventories
RemoveOldCoreInventories = false, -- Remove old core inventories during conversion
```

If `RemoveOldCoreInventories` is set to `true`, it is recommended to back up the following tables just in case you want to switch back:

```
stashitems
trunkitems
gloveboxitems
```

### Note:
- QB integration will attempt to stop `qb-inventory`, `qb-shop`, and `qb-weapons` as this inventory will replace those.

### Setup targetting

- In `server.cfg`, set `setr UseTarget true`
- In `ps-inventory` set `Config.Target` to either `qb` or `ox`

### Decay system

To activate the decay system:

For QBCore, add the following to an item in `qb-core/shared/items.lua`

```
item_name = { ..., decay = 5 } -- Decay is in minutes
```

### Available Server Exports

```
exports['ps-inventory']:Items() -- Returns loaded items
exports['ps-inventory']:ItemExists(item) -- Checks if item exists in loaded items
exports['ps-inventory']:GetPlayerInventory(src) -- Gets player inventory items
exports['ps-inventory']:SaveInventory(src, inventory) -- Saves player inventory
exports['ps-inventory']:SavePlayerInventory(src, inventory) -- Saves player inventory (Alias for SaveInventory)
exports['ps-inventory']:GetTotalWeight(items) -- Get total weight of items
exports['ps-inventory']:HasItem(source, items, count) -- Checks if player has item in inventory
exports['ps-inventory']:GetSlot(src, slot) -- Gets item data for a specific slot
exports['ps-inventory']:GetSlotNumberWithItem(src, itemName) -- Gets the slot number of an item in inventory
exports['ps-inventory']:GetSlotWithItem(src, itemName, items) -- Gets the slot data for specified item
exports['ps-inventory']:GetSlotsWithItem(src, itemName) -- Get list of slots with item
exports['ps-inventory']:OpenInventory(src, external) -- Opens player inventory
exports['ps-inventory']:CloseInventory(src) -- Closes player inventory
exports['ps-inventory']:CanCarryItem(source, item, amount, maxWeight) -- Checks if item can be carried
exports['ps-inventory']:OpenInventoryById(src, target) -- Opens target player inventory
exports['ps-inventory']:CreateUseableItem(itemName, data) -- Creates a useable item
exports['ps-inventory']:ValidateAndUseItem(src, itemData) -- Validates item data and uses it
exports['ps-inventory']:AddItem(source, item, amount, slot, info, reason, created) -- Adds item to inventory
exports['ps-inventory']:RemoveItem(source, item, amount, slot) -- Removes item from inventory
exports['ps-inventory']:ClearInventory(source, filterItems) -- Clears a player's inventory
exports['ps-inventory']:SaveExternalInventory(type, inventoryId, items) -- Saves an external inventory item list
exports['ps-inventory']:LoadExternalInventory(type, typeId) -- Loads an external inventory item list
exports['ps-inventory']:OpenStash(src, stashId) -- Opens a stash
exports['ps-inventory']:OpenShop(src, shopId) -- Opens a shop
exports['ps-inventory']:OpenVending() -- Opens vending machine shop
exports['ps-inventory']:OpenCrafting(src, craftId) -- Opens crafting menu
exports['ps-inventory']:DisarmWeapon(src) -- Disarms weapon for source
```

### Client Exports

```
exports['ps-inventory']:OpenInventory() -- Opens player inventory
exports['ps-inventory']:CloseInventory() -- Closes player inventory
exports['ps-inventory']:UseWeapon(weaponData, canFire) -- Use weapon
exports['ps-inventory']:DisarmWeapon() -- Disarms weapon
exports['ps-inventory']:ReloadWeapon() -- Reloads weapon
```

### Creating Useable Items
```
exports['ps-inventory']:CreateUseableItem(itemName, function (source, item)
    -- Do logic here
end)
```

### Adding Additional Items

- You can add additional items to your framework, or
- You can add them to the `config/items.config.lua`

Example:

```
id_card = { 
    name = 'id_card', 
    label = 'ID Card', 
    weight = 0, 
    type = 'item', 
    image = 'id_card.png', 
    unique = true, 
    useable = true, 
    shouldClose = false, 
    description = 'A card containing all your information to identify yourself',

    onUse = function (source, item)
        -- Do what you want here
    end
},

...
```

### Credits

- Placeables logic heavily based on: @WaypointRP/wp-placeables
