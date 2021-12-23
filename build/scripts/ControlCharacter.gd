extends Node2D

onready var session  = get_node("/root/Session") # Get access to global script property such as current day(for loading and saving)
var oldPosition
var isLeave = false
var defAnim

func _ready():
	oldPosition = position
func walk_to(var pos, var how_f):
	var tw = get_node("Tween")
	if (tw != null):
		if (pos.x > position.x):
			get_node("Sprite").play("walk");
			get_node("Sprite").flip_h = false
		else:
			get_node("Sprite").play("walk");
			get_node("Sprite").flip_h = true
		get_node("Tween").interpolate_property(self,"position:x",self.position.x,pos.x,abs(position.x - pos.x)/how_f,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
		get_node("Tween").start()
	else:
		position = pos
func leave(var pos):
	isLeave = true
	if (pos > position):
		get_node("Sprite").play("walk");
		get_node("Sprite").flip_h = false
	else:
		get_node("Sprite").play("walk");
		get_node("Sprite").flip_h = true
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
		else:
			get_node("Sprite").play("idle");


func _on_Sprite_animation_finished():
	if get_node("Sprite").animation == "talk":
		get_node("Sprite").play("idle")

func _on_AnimatedSprite_animation_finished():
	if get_node("AnimatedSprite").animation == "talk":
		get_node("AnimatedSprite").play("idle")
	if get_node("AnimatedSprite").animation == "jump" or get_node("AnimatedSprite").animation == "fallFromSurf" or get_node("AnimatedSprite").animation == "usingPress":
		if get_node("Camera2D/HUD/ControlInterface").velocity.x >= 5:
			get_node("AnimatedSprite").play("run")
			get_node("AnimatedSprite").flip_h = false
		elif get_node("Camera2D/HUD/ControlInterface").velocity.x <= -5:
			get_node("AnimatedSprite").play("run")
			get_node("AnimatedSprite").flip_h = true
		else:
			get_node("AnimatedSprite").play("idle")
			get_node("AnimatedSprite").flip_h = false
