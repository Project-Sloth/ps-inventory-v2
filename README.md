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
- Trunk system
- Glovebox system
- Targetting support for qb-target and ox_target
- Interactive UI when targetting is not available
- Decay system
- Hotbar (With toggling capability) (Coming Soon)

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
exports("Items", Core.Classes.Inventory.Items)
exports("ItemExists", Core.Classes.Inventory.ItemExists)
exports("GetPlayerInventory", Core.Classes.Inventory.GetPlayerInventory)
exports("SaveInventory", Core.Classes.Inventory.SaveInventory)
exports("SavePlayerInventory", Core.Classes.Inventory.SaveInventory)
exports("GetTotalWeight", Core.Classes.Inventory.GetTotalWeight)
exports("HasItem", Core.Classes.Inventory.HasItem)
exports("GetSlot", Core.Classes.Inventory.GetSlot)
exports("GetSlotNumberWithItem", Core.Classes.Inventory.GetSlotNumberWithItem)
exports("GetSlotWithItem", Core.Classes.Inventory.GetSlotWithItem)
exports("GetSlotsWithItem", Core.Classes.Inventory.GetSlotsWithItem)
exports("OpenInventory", Core.Classes.Inventory.OpenInventory)
exports("OpenInventoryById", Core.Classes.Inventory.OpenInventoryById)
exports("CloseInventory", Core.Classes.Inventory.CloseInventory)
exports("CreateUseableItem", Core.Classes.Inventory.CreateUseableItem)
exports("ValidateAndUseItem", Core.Classes.Inventory.ValidateAndUseItem)
exports("UseItem", Core.Classes.Inventory.UseItem)
exports("AddItem", Core.Classes.Inventory.AddItem)
exports("RemoveItem", Core.Classes.Inventory.RemoveItem)
exports("ClearInventory", Core.Classes.Inventory.ClearInventory)
exports("SaveExternalInventory", Core.Classes.Inventory.SaveExternalInventory)
exports("LoadExternalInventory", Core.Classes.Inventory.LoadExternalInventory)
exports("Move", Core.Classes.Inventory.Move)
exports("OpenStash", Core.Classes.Inventory.OpenStash)
exports("OpenShop", Core.Classes.Shops.Open)
```

### Client Exports

```
exports('OpenInventory', Core.Classes.Inventory.Open)
exports('CloseInventory', Core.Classes.Inventory.Close)
```

### QB Exports that are overrided

```
qb-inventory - HasItem
qb-inventory - RemoveItem
qb-inventory - AddItem
qb-inventory - OpenInventory
```

### Credits

- Placeables logic heavily based on: @WaypointRP/wp-placeables