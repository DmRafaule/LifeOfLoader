extends Node2D

onready var session  = get_node("/root/Session") # Get access to global script property such as current day(for loading and saving)

func _ready():
	pass
func walk_to(var pos):
	pass
func say(var text):
	get_tree().get_root().get_node("WorkSession").createDialogWin(text,name)
