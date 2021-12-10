extends TouchScreenButton

func _ready():
	pass # Replace with function body.


func _on_quit_pressed():
	get_tree().quit();


func _on_play_pressed():
	# Chang this to intro
	get_tree().change_scene("res://scenes/WorkSession.tscn");
