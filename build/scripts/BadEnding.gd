extends Node2D
onready var session  = get_node("/root/Session")

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
	
func _ready():
	pass # Replace with function body.
