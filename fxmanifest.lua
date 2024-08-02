fx_version "cerulean"

description "PS Inventory"
author "Project Sloth"
version '2.0.0'
lua54 'yes'
games { "gta5" }

client_script {
    "client/classes/*.lua",
    "client/events/*.lua",
    "client/functions.lua",
    "client/init.lua",
    "client/threads/*.lua",
}

server_script { 
    '@oxmysql/lib/MySQL.lua', 
    "server/classes/*.lua",
    "server/callbacks/*.lua",
    "server/events/*.lua",
    "server/init.lua",
    "server/setup/*.lua",
    "server/commands/*.lua",
    "server/threads/*.lua",
}

shared_script { 
    "@ox_lib/init.lua",
    "shared/config.lua",
    "shared/shops.config.lua",
    "shared/stashes.config.lua",
    "shared/vehicles.config.lua",
    "shared/core/utilities.lua",
    "shared/core/classes.lua",
    "shared/core/framework.lua"
}

files { 
    'nui/**/*',
    'bridge/**/*.lua'
}

ui_page 'nui/index.html'