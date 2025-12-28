fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'BK Union Scripts'
description 'BK Union - Bottlespin for [QBOX]'
version '1.0.1'

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

escrow_ignore {
    'config.lua'   
}

dependencies {
    'qbx_core',
    'ox_lib',
    'ox_inventory'
}
