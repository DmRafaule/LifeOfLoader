extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Next_pressed():
	get_tree().get_root().get_node("WorkSession/blur").visible = false
	get_tree().get_root().get_node("WorkSession/EndDay").paused = false
	get_tree().get_root().get_node("WorkSession").isEndDay = false
	get_tree().get_root().get_node("WorkSession/Building/mch/Camera2D/HUD/ControlInterface").visible = true
	var node =	get_tree().get_root().get_node("WorkSession/Building/mch/Camera2D/HUD/PopupMenu")
	get_tree().get_root().get_node("WorkSession/Building/mch/Camera2D/HUD").remove_child(node) 


func _on_Exit_pressed():
	get_tree().change_scene("res://scenes/Main.tscn")


func _on_Settings_pressed():
	pass # Replace with function body.


func _on_Credits_pressed():
	pass # Replace with function body.
