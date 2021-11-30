extends Node2D

onready var session  = get_node("/root/Session") # Get access to global script property such as current day(for loading and saving)

func _ready():
	show()

func show():
	get_node("Sprite").visible = true
	get_node("AnimationPlayer").play("GUI1")
func hide():
	get_node("RichTextLabel").visible = false
	get_node("AnimationPlayer").play("GUI2")

func _on_AnimationPlayer_animation_finished(anim_name):
	match(anim_name):
		"GUI1": # Showin up
			session.isEndPhrase = false
			get_node("AnimationPlayer").play("play_text")
		"GUI2":
			remove_child(get_node("AnimationPlayer"))
			remove_child(get_node("RichTextLabel"))
			remove_child(get_node("Sprite"))
			remove_child(get_node("Sprite2"))
			remove_child(get_node("Sprite3"))
			remove_and_skip()
			session.isEndPhrase = true
		"play_text":
			hide()


func _on_AnimationPlayer_animation_started(anim_name):
	pass

