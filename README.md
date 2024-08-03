# PS Inventory V2

Currently a work-in-progress. Do not expect this to fully work yet.

### Dependencies

- `oxmysql`
- `ox_lib`
- `qb-core` (Only integration at the moment)

### Server Exports

```
exports("Items", Classes.Inventory.Items)
exports("ItemExists", Classes.Inventory.ItemExists)
exports("GetPlayerInventory", Classes.Inventory.GetPlayerInventory)
exports("SaveInventory", Classes.Inventory.SaveInventory)
exports("SavePlayerInventory", Classes.Inventory.SaveInventory)
exports("GetTotalWeight", Classes.Inventory.GetTotalWeight)
exports("HasItem", Classes.Inventory.HasItem)
exports("GetSlot", Classes.Inventory.GetSlot)
exports("GetSlotNumberWithItem", Classes.Inventory.GetSlotNumberWithItem)
exports("GetSlotWithItem", Classes.Inventory.GetSlotWithItem)
exports("GetSlotsWithItem", Classes.Inventory.GetSlotsWithItem)
exports("OpenInventory", Classes.Inventory.OpenInventory)
exports("OpenInventoryById", Classes.Inventory.OpenInventoryById)
exports("CloseInventory", Classes.Inventory.CloseInventory)
exports("CreateUseableItem", Classes.Inventory.CreateUseableItem)
exports("ValidateAndUseItem", Classes.Inventory.ValidateAndUseItem)
exports("UseItem", Classes.Inventory.UseItem)
exports("AddItem", Classes.Inventory.AddItem)
exports("RemoveItem", Classes.Inventory.RemoveItem)
exports("ClearInventory", Classes.Inventory.ClearInventory)
exports("SaveExternalInventory", Classes.Inventory.SaveExternalInventory)
exports("LoadExternalInventory", Classes.Inventory.LoadExternalInventory)
exports("Move", Classes.Inventory.Move)
exports("OpenStash", Classes.Inventory.OpenStash)
exports("OpenShop", Classes.Shops.Open)
```

### Client Exports

```
exports('OpenInventory', Classes.Inventory.Open)
exports('CloseInventory', Classes.Inventory.Close)
```