function love.conf(t)
	t.identity = "ttmps"
	t.version = "11.5"
	
	t.window.width = 265
	t.window.height = 165
	t.window.title = "ttmps"
	t.window.icon = "icon.png"
	
    t.modules.joystick = false
    t.modules.physics = false
end