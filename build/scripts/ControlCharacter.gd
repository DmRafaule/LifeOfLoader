extends Node2D

onready var session  = get_node("/root/Session") # Get access to global script property such as current day(for loading and saving)
var oldPosition
var isLeave = false

func _ready():
	oldPosition = position
func walk_to(var pos, var how_f):
	var tw = get_node("Tween")
	if (tw != null):
		get_node("Tween").interpolate_property(self,"position:x",self.position.x,pos.x,abs(position.x - pos.x)/how_f,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
		get_node("Tween").start()
	else:
		position = pos
func leave(var pos):
	isLeave = true
	get_node("Tween").interpolate_property(self,"position:x",self.position.x,pos.x,abs(position.x - pos.x)/150,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	get_node("Tween").start()
func say(var text):
	get_tree().get_root().get_node("WorkSession").createDialogWin(text,name)


func _on_Tween_tween_completed(object, key):
	if (key == ":position:x"):
		if (isLeave):
			remove_child(get_node("Sprite"))
			remove_child(get_node("AnimationPlayer"))
			remove_child(get_node("Tween"))
			remove_and_skip()
