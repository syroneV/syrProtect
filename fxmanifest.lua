fx_version 'adamant'
games { 'gta5' }

lua54 'yes'
author ('syrone')
version '2.0'
escrow_ignore {
  'config.lua',
  'shared.lua',
  'tables/*.lua'
}
client_scripts {
  '@es_extended/locale.lua',
  'anti-dump/client/*.lua',
  'config.lua',
  "client/*.lua",
}

server_scripts {
  '@es_extended/locale.lua',
  "@oxmysql/lib/MySQL.lua",
  "@mysql-async/lib/MySQL.lua",
  'anti-dump/server/*.lua',
  "server/*.lua",
}

shared_scripts {
  '@es_extended/imports.lua',
  'tables/*.lua',
  'config.lua',
  'shared.lua'
}