fx_version "cerulean"

description "PS Inventory"
author "Project Sloth"
version '2.0.0'
lua54 'yes'
games { "gta5" }

client_script {
    "framework/base/client.lua",
    "client/classes/*.lua",
    "client/events/*.lua",
    "client/functions.lua",
    "client/init.lua"
}

server_script { 
    '@oxmysql/lib/MySQL.lua',
    "framework/base/server.lua",
    "server/classes/*.lua",
    "server/callbacks/*.lua",
    "server/events/*.lua",
    "server/init.lua",
    "server/commands/*.lua",
}

shared_script { 
    "@ox_lib/init.lua",
    "config/config.lua",
    "config/items.config.lua",
    "config/shops.config.lua",
    "config/stashes.config.lua",
    "config/vehicles.config.lua",
    "config/crafting.config.lua",
    "config/weapons.config.lua",
    "shared/core/utilities.lua",
    "shared/core/language.lua",
    "shared/core/classes.lua",
    "shared/core/crons.lua",
    "framework/framework.lua"
}

files { 
    'nui/assets/**/*',
    'nui/index.html',
    'framework/**/*.lua'
}

ui_page 'nui/index.html'