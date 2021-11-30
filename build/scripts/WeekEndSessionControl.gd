extends Node2D


onready var session  = get_node("/root/Session")
var savePath : String= "user://save.txt" # Where to save

func saving():	
	session.current_day+=1
	var file = File.new()
	# Copy data to buffer
	file.open(savePath,file.READ)
	var schedule : Dictionary = {
		"name"			: "day",
		"current_day" 	: var2str(session.current_day)
	}
	var data = [] 
	data.append(schedule)
	while file.get_position() < file.get_len():
		data.append(parse_json(file.get_line()))
	file.close()
	data.remove(1)
	# Rewrite save file from buffer
	file.open(savePath,file.WRITE)
	for d in data:
		file.store_line(to_json(d))
	file.close()

func _ready():
	pass


func _on_Timer_timeout():
	saving()
	if (session.month[session.current_day] == "work"):
		get_tree().change_scene("res://scenes/FromHomeToWork.tscn")
	elif (session.month[session.current_day] == "free"):
		get_tree().change_scene("res://scenes/WeekEndSession.tscn")
