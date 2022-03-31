fx_version 'cerulean'

game 'gta5'

author 'Giana'
description 'billing'

shared_script 'config.lua'

client_scripts {
	'client.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server.lua',
}

dependencies {
	'qb-core',
	'qb-input',
	'qb-management',
	'qb-menu'
}

lua54 'yes'