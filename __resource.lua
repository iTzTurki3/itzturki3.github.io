files {
    'html/**.*',
}
ui_page 'html/index.html'
client_script {
    'config.lua',
    'client.lua',
}
server_script {
    "@vrp/lib/utils.lua",
    'config.lua',
    'server.lua',
}