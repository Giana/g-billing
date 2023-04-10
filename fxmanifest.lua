fx_version 'cerulean'

game 'gta5'

author 'Giana - github.com/Giana'
description 'g-billing'
version '2.0.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'locales/en.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

dependencies {
    'qb-core'
}

lua54 'yes'