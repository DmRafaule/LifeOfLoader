extends Node2D

onready var session  = get_node("/root/Session")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	if (session.month[session.current_day] == "work"):
		get_tree().change_scene("res://scenes/FromHomeToWork.tscn")
	elif (session.month[session.current_day] == "free"):
		get_tree().change_scene("res://scenes/WeekEndSession.tscn")
