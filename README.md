# PS Inventory V2

Currently a work-in-progress. Do not expect this to fully work yet. The goal is to make this inventory work out of the box for a fresh install of the new QBCore update.

### Frameworks Supported
- QB Core

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

### Dependencies

- `oxmysql`
- `ox_lib`
- `qb-core`

### Installation

- Download the resource from the repo
- Drop the resource into your qb server resources
- Run `__install/database.sql` in your database
- Start resource in server.cfg after qb-core or esx core (If using targetting, make sure qb-target or ox_target is started before)
- Remove `qb-inventory` (If using QB Core)
- Restart server

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
exports['ps-inventory']:CreateUseableItem(src) -- Creates a useable item
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
```

### Client Exports

```
exports['ps-inventory']:OpenInventory() -- Opens player inventory
exports['ps-inventory']:CloseInventory() -- Closes player inventory
```

### Credits

- Placeables logic heavily based on: @WaypointRP/wp-placeables