fx_version 'cerulean'
game 'gta5'

description 'BK Bottle Spin Script for qbx_core'
version '1.0.0'
author 'BK Union Studios'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

dependencies {
    'qbx_core',
    'ox_lib',
    'ox_inventory'
}
