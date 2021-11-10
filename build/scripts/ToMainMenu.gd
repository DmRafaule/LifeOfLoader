extends Node2D

# This scrip provide functionality for moving between scenes

func _input(event):
	if (event is InputEventScreenTouch):
		get_tree().change_scene("res://scenes/Main.tscn")
	elif (event is InputEventMouseButton):
		get_tree().change_scene("res://scenes/Main.tscn")
	elif (event is InputEventKey):
		get_tree().change_scene("res://scenes/Main.tscn")

func _on_AnimationPlayer_animation_finished(_anim_name):
	get_tree().change_scene("res://scenes/Main.tscn")


