-------------------------------------------------
--- Version and status
-------------------------------------------------

local version = GetResourceMetadata(GetCurrentResourceName(), 'version')

print('--------------------------------------------------')
print('|                                                |')
print('|                   PS INVENTORY                 |')
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
Core.Classes.Inventory:Load(true)