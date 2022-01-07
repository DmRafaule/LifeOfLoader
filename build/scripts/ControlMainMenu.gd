extends TouchScreenButton
onready var session  = get_node("/root/Session") # Get access to global script property such as current day(for loading and saving)
var isPressed = false 

func _ready():
	pass # Replace with function body.


func _on_quit_pressed():
	get_tree().quit();


func _on_play_pressed():
	get_tree().get_root().get_node("MainMenu/SoundTouchB").play(0.10)
	if !isPressed:
		get_tree().get_root().get_node("MainMenu/fg/blur").material.set_shader_param("blur_amount", 3.051)
		get_tree().get_root().get_node("MainMenu/fg/blur").material.set_shader_param("mix_amount", 0.241)
		get_tree().get_root().get_node("MainMenu/fg/blur").material.set_shader_param("circleRadius", Vector2(0.5,0.1))
		isPressed = true
		var res = load("res://scenes/ContOrNew.tscn").instance()
		get_tree().get_root().get_node("MainMenu/HUD").add_child(res)
		var file = File.new()
		if file.file_exists(session.savePath):
			res.get_node("new").visible = true
			res.get_node("cont").visible = true
		else:
			res.get_node("new").visible = true
			res.get_node("cont").visible = false
	else:
		get_tree().get_root().get_node("MainMenu/fg/blur").material.set_shader_param("blur_amount", 2.0)
		get_tree().get_root().get_node("MainMenu/fg/blur").material.set_shader_param("mix_amount", 0.0)
		get_tree().get_root().get_node("MainMenu/fg/blur").material.set_shader_param("circleRadius", Vector2(0.1,0.7))
		isPressed = false
		get_tree().get_root().get_node("MainMenu/HUD").remove_child(get_tree().get_root().get_node("MainMenu/HUD").get_node("Control"))


func _on_TouchScreenButton_pressed():
	get_tree().get_root().get_node("MainMenu/SoundTouchB").play(0.10)
	if !isPressed:
		get_tree().get_root().get_node("MainMenu/fg/blur").material.set_shader_param("blur_amount", 3.051)
		get_tree().get_root().get_node("MainMenu/fg/blur").material.set_shader_param("mix_amount", 0.241)
		get_tree().get_root().get_node("MainMenu/fg/blur").material.set_shader_param("circleRadius", Vector2(0.5,0.1))
		isPressed = true
		var res = load("res://scenes/Credentials.tscn").instance()
		get_tree().get_root().get_node("MainMenu/HUD").add_child(res)
		
	else:
		get_tree().get_root().get_node("MainMenu/fg/blur").material.set_shader_param("blur_amount", 2.0)
		get_tree().get_root().get_node("MainMenu/fg/blur").material.set_shader_param("mix_amount", 0.0)
		get_tree().get_root().get_node("MainMenu/fg/blur").material.set_shader_param("circleRadius", Vector2(0.1,0.7))
		isPressed = false
		get_tree().get_root().get_node("MainMenu/HUD").remove_child(get_tree().get_root().get_node("MainMenu/HUD").get_node("Control"))

