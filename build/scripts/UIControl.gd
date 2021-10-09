extends TextureButton

func _ready():
	pass # Replace with function body.


func _on_quit_pressed():
	get_tree().quit();


func _on_play_pressed():
	get_tree().change_scene("res://scenes/FromHomeToWork.tscn");
