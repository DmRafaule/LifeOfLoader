extends Node2D
onready var session  = get_node("/root/Session")

func _ready():
	pass # Replace with function body.
func _input(event):
	if event is InputEventScreenTouch:
		get_node("G/AnimatedSprite/Camera2D/TouchScreenButton").visible = true
		
func end():
	get_node("AnimationPlayer").play("end")
func to_main():
	var dir = Directory.new()
	dir.remove(session.savePath)
	session.current_hour = 12
	session.current_day = 1
	session.cash = 0
	session.dialogs = [] # dialogs data
	session.current_dialog_win = 0 # current dialog context
	session.isEndPhrase   = false # is resources free and can prog call createDialogWin
	session.isDialogStart = false # this is exist only for one reason do not play animation for apearing UI if it is just random phase
	session.lethalMistakes = 0 # Counter for lethal(end game)
	session.setCharacters = [] # who is acting in this day
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
