extends Node2D


func _ready():
	pass # Replace with function body.
func _input(event):
	if event is InputEventScreenTouch:
		get_node("G/AnimatedSprite/Camera2D/TouchScreenButton").visible = true
		
func end():
	get_node("AnimationPlayer").play("end")
func to_main():
	get_tree().change_scene("res://scenes/Main.tscn")

func _on_VisibilityNotifier2D_screen_entered():
	get_node("BG/strangers/stranger/AnimationPlayer").play("walk")
	get_node("BG/strangers/stranger2/AnimationPlayer").play("walk")
	get_node("BG/strangers/stranger3/AnimationPlayer").play("walk")


func _on_VisibilityNotifier2D2_screen_entered():
	get_node("BG/strangers/stranger4/AnimationPlayer").play("walk")
	get_node("BG/strangers/stranger5/AnimationPlayer").play("walk")
	get_node("BG/strangers/stranger6/AnimationPlayer").play("walk")



func _on_VisibilityNotifier2D3_screen_entered():
	get_node("BG/strangers/stranger7/AnimationPlayer").play("walk")
	get_node("BG/strangers/stranger8/AnimationPlayer").play("walk")
	get_node("BG/strangers/stranger9/AnimationPlayer").play("walk")



func _on_VisibilityNotifier2D4_screen_entered():
	get_node("BG/strangers/stranger10/AnimationPlayer").play("walk")
	get_node("BG/strangers/stranger11/AnimationPlayer").play("walk")
	get_node("BG/strangers/stranger12/AnimationPlayer").play("walk")




func _on_TouchScreenButton_pressed():
	get_node("AnimationPlayer").play("end")
