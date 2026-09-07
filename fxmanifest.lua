fx_version 'cerulean'
game 'gta5'

lua54 'yes'

name 'CCD_BlackMarket'
author 'CodeCraft Developments'
description 'Framework-agnostic buy-only black market using CCD-Library'
version '1.0.0'

ui_page 'ui/index.html'

files {
    'ui/*',
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    'server/main.lua',
    'server/versionchecker.lua'
}

dependencies {
    'CCD-Library',
}
