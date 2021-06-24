fx_version 'adamant'
games { 'gta5' }
author 'https://github.com/Delarmuss'
version '1.0'

client_scripts {
	'client.lua'
}

ui_page('ui/index.html')

files({
	"ui/*.html",
	"ui/css/*.css",
	"ui/font/*.ttf",
	"ui/img/*.svg",
	"ui/js/*.js",
	"ui/sounds/*.ogg",
})