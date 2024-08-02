-------------------------------------------------
--- Version and status
-------------------------------------------------

local version = GetResourceMetadata(GetCurrentResourceName(), 'version')

print('--------------------------------------------------')
print('|                                                |')
print('|                  IR8 INVENTORY                 |')
print('|                     STARTED                    |')
print('|                  VERSION ' .. version .. '                 |')
print('|                                                |')
print('--------------------------------------------------')

-------------------------------------------------
--- Setup Functions
-------------------------------------------------

-- Determine framework
Framework.Determine()

-- Load the inventory items
Classes.Inventory:Load()