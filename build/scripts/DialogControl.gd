extends Node2D

onready var session  = get_node("/root/Session") # Get access to global script property such as current day(for loading and saving)
var type
func _ready():
	get_node("AnimationPlayer").method_call_mode = AnimationPlayer.ANIMATION_METHOD_CALL_IMMEDIATE
	show()

func show():
	get_node("Sprite").visible = true
	get_node("AnimationPlayer").play("GUI1")
func hide():
	get_node("RichTextLabel").visible = false
	get_node("AnimationPlayer").play("GUI2")
func play_text():
	var charas = 9
	if (type == "Employee"):
		charas = 15 
	var time = 1
	var speed = charas/time
	var tx = get_node("RichTextLabel")
	var tw = get_node("Tween")
	tw.interpolate_property(tx,"visible_characters",0,tx.text.length()+1,(tx.text.length()+1)/speed,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	tw.start()

func _on_AnimationPlayer_animation_finished(anim_name):
	match(anim_name):
		"GUI1": # Showin up
			play_text()
		"GUI2":
			remove_child(get_node("AnimationPlayer"))
			remove_child(get_node("RichTextLabel"))
			remove_child(get_node("Sprite"))
			remove_child(get_node("Sprite2"))
			remove_child(get_node("Sprite3"))
			remove_and_skip()
			if (type == "Employee"):
				session.isEndPhrase = true


func _on_AnimationPlayer_animation_started(anim_name):
	pass



func _on_Tween_tween_completed(object, key):
	if key == ":visible_characters":
		var tx = get_node("RichTextLabel")
		var tw = get_node("Tween")
		tw.interpolate_property(tx,"tab_size",4,4,1,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
		tw.start()
	elif key == ":tab_size":
		if (type == "Employee"):
			session.isEndPhrase = false
		hide()
