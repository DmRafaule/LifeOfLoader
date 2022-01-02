extends TouchScreenButton
onready var session  = get_node("/root/Session") # Get access to global script property such as current day(for loading and saving)
var isPressed = false 

func _ready():
	pass # Replace with function body.


func _on_quit_pressed():
	get_tree().quit();


func _on_play_pressed():
	if !isPressed:
		get_tree().get_root().get_node("MainMenu/fg/blur").visible = true
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
		get_tree().get_root().get_node("MainMenu/fg/blur").visible = false
		isPressed = false
		get_tree().get_root().get_node("MainMenu/HUD").remove_child(get_tree().get_root().get_node("MainMenu/HUD").get_node("Control"))
