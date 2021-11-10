extends Node2D

var sSRect = Rect2(Vector2(825,200),Vector2(330,330));
var TZRect = Rect2(Vector2(-550,300),Vector2(1200,130));
var goodies = []
onready var session  = get_node("/root/Session")
onready var boxP = get_node("Building/boxes")

var savePath : String= "user://save.txt"

func saving():
	
	session.current_day+=1
	var file = File.new()
	file.open(savePath,file.WRITE_READ)
	var schedule : Dictionary = {
		"name"			: "day",
		"current_day" 	: var2str(session.current_day)
	}
	file.store_line(to_json(schedule))
	for saved_node in get_tree().get_nodes_in_group("save"):
		match(saved_node.nameStr):
			"box":
				var data : Dictionary = {
					"position" : var2str(saved_node.get_position()),
					"name"	   : var2str(saved_node.nameStr),
					"content"  : var2str(saved_node.nameGoodie),
					"num"	   : var2str(saved_node.numberOfGoodie),
					"type"	   : var2str(saved_node.boxType),
					"isOpend"   : var2str(saved_node.isOpend)
				}
				file.store_line(to_json(data))
			"goodie":
				var data : Dictionary = {
					"position" : var2str(saved_node.get_position()),
					"name"	   : var2str(saved_node.nameStr),
					"content"  : var2str(saved_node.nameGoodie),
					"num"	   : var2str(saved_node.numberOfGoodie),
					"type"	   : var2str(saved_node.boxType),
					"isOpend"   : var2str(saved_node.isOpend)
				}
				file.store_line(to_json(data))
			"platform":
				var data : Dictionary = {
					"position" : var2str(saved_node.get_position()),
					"name"	   : var2str(saved_node.nameStr),
				}	
				file.store_line(to_json(data))
			"press":
				var data : Dictionary = {
					"box_counter" : var2str(saved_node.boxesCounter),
					"name"	   : var2str(saved_node.nameStr),
				}	
				file.store_line(to_json(data))
	file.close()
	
	
func loading():
	var file = File.new()
	if file.file_exists(savePath):	
		file.open(savePath,file.READ)
		while file.get_position() < file.get_len():
			var data = parse_json(file.get_line())
			match(str2var(data["name"])):
				"box":
					createBox(str2var(data["type"]),str2var(data["position"]),str2var(data["content"]),str2var(data["num"]),str2var(data["isOpend"]))
				"goodie":
					createGoodie(str2var(data["position"]),str2var(data["content"]),1)
				"platform":
					get_tree().get_root().get_node("WorkSession/Building/platform").set_position(str2var(data["position"]))
				"press":
					get_tree().get_root().get_node("WorkSession/Building/press_counter/counter").text = str(data["box_counter"])
					get_tree().get_root().get_node("WorkSession/Building/press").boxesCounter = str2var(data["box_counter"])
				"day":
					session.current_day = str2var(data["current_day"])
					match(str2var(data["current_day"])):
						1:
							pass
						2:
							pass
						3:
							pass
						4:
							pass
						5:
							pass
						6:
							pass
						7:
							pass
						8:
							pass
						9:
							pass
						10:
							pass
						11:
							pass
						12:
							pass
						13:
							pass
						14:
							pass
						15:
							pass
						16:
							pass
						17:
							pass
						18:
							pass
						19:
							pass
						20:
							pass
						21:
							pass
						22:
							pass
						23:
							pass
						24:
							pass
						25:
							pass
						26:
							pass
						27:
							pass
						28:
							pass
						29:
							pass
						30:
							pass
							print(str2var(data["current_day"]))
		file.close()
	else:
		var rnd    = RandomNumberGenerator.new()	
		rnd.randomize()
		var sW = Vector2(sSRect.position.x - boxP.position.x,sSRect.position.x + sSRect.size.x - boxP.position.x)
		var sH = Vector2(sSRect.position.y - boxP.position.y,sSRect.position.y + sSRect.size.y - boxP.position.y)
		var types = getAllTypesOfGoodies()
		# Create boxes
		for i in range(0,20):
			createBox(str(int(rnd.randf_range(0,5))),
				  Vector2(int(rnd.randf_range(sW.x,sW.y)),int(rnd.randf_range(sH.x,sH.y))),
				  str(types[int(rnd.randf_range(0,types.size()))]),
				  int(rnd.randf_range(1,5)))
		# Create goodies
		for i in range(0,20):
			createGoodie(Vector2(int(rnd.randf_range(TZRect.position.x,TZRect.position.x+TZRect.size.x)),int(rnd.randf_range(TZRect.position.y,TZRect.position.y+TZRect.size.y))),
					str(types[int(rnd.randf_range(0,types.size()))]),
					int(rnd.randf_range(1,3)))

func createGoodie(var pos, var name, var number):
	for i in range(0,number):
		var res = load("res://scenes/goodies/" + (str(name).replace(".png","")) + ".tscn").instance()
		res.add_to_group("save")
		res.nameGoodie = name
		res.nameStr = "goodie"
		res.isOpend = true
		res.position = pos
		goodies.push_back(res)
		get_tree().get_root().get_node("WorkSession/Building").add_child(res)
func createBox(var type, var pos, var content, var num, var isOpend = false):
	var box = load("res://scenes/boxes/box" + type + ".tscn").instance()
	box.add_to_group("save")
	box.nameStr = "box"
	box.boxType = type
	box.set_position(pos)
	box.setBoxGoodie(content,num)
	if (isOpend):
		box.setBoxGoodie("empty_box",0)
		var previousHeight = box.get_node("Sprite").get_rect().size.y
		var newImageForBox :StreamTexture = load("res://textures/boxes/box_opened" + str(box.boxType) + ".png")
		box.get_node("Sprite").texture = newImageForBox
		var newHeight = box.get_node("Sprite").get_rect().size.y
		box.get_node("CollisionShape2D").position += Vector2(0,(newHeight - previousHeight)/2 )
	box.z_index = 3
	get_node("Building/boxes").add_child(box)
func createTray(pos):
	var obj = load("res://scenes/tray.tscn").instance()
	obj.add_to_group("save")
	obj.set_position(Vector2(1400,450))
	get_tree().get_root().call_deferred("add_child",obj)
func getAllTypesOfGoodies():
	var files = []
	var dir = Directory.new()
	dir.open("res://textures/goodies")
	dir.list_dir_begin()
	
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif file.ends_with(".import"):
			files.append(file.replace(".import",""))# This replace stuff was made for adding supported images
	
	dir.list_dir_end()
	return files

func _ready():
	loading()

func _on_leftBuildingNotifier_screen_entered():
	for i in range(11,15):
		get_node("BG/bushes/bushe" + String(i) + "/AnimationPlayer").play("idle")
	for i in range(4,6):
		get_node("BG/lighters/ligherAtStreet" + String(i) + "/Light2D").enabled = true
func _on_leftBuildingNotifier_screen_exited():
	for i in range(11,15):
		get_node("BG/bushes/bushe" + String(i) + "/AnimationPlayer").stop(false)
	for i in range(4,6):
		get_node("BG/lighters/ligherAtStreet" + String(i) + "/Light2D").enabled = false

func _on_rightBuildingNotifier_screen_entered():
	for i in range(7,11):
		get_node("BG/bushes/bushe" + String(i) + "/AnimationPlayer").play("idle")
	get_node("BG/lighters/ligherAtStreet3/Light2D").enabled = true
func _on_rightBuildingNotifier_screen_exited():
	for i in range(7,11):
		get_node("BG/bushes/bushe" + String(i) + "/AnimationPlayer").stop(false)
	get_node("BG/lighters/ligherAtStreet3/Light2D").enabled = false

func _on_bushesNotifier_screen_entered():
	for i in range(1,9):
		get_node("BG/trees/animated_tree" + String(i) +"/AnimationPlayer").play("Wind")
	for i in range(-4,7):
		get_node("BG/bushes/bushe" + String(i) + "/AnimationPlayer").play("idle")
	for i in range(1,3):
		get_node("BG/lighters/ligherAtStreet" + String(i) + "/Light2D").enabled = true
	get_node("BG/Particles2D2").emitting = true
	get_node("FG/animated_tree1/AnimationPlayer").play("wind")
func _on_bushesNotifier_screen_exited():
	for i in range(1,9):
		get_node("BG/trees/animated_tree" + String(i) +"/AnimationPlayer").stop(false)
	for i in range(-4,7):
		get_node("BG/bushes/bushe" + String(i) + "/AnimationPlayer").stop(false)
	for i in range(1,3):
		get_node("BG/lighters/ligherAtStreet" + String(i) + "/Light2D").enabled = false
	get_node("BG/Particles2D2").emitting = false
	get_node("FG/animated_tree1/AnimationPlayer").stop(false)


func _on_EndDay_timeout():
	saving()
	#pop up result screen
	get_tree().change_scene("res://scenes/WorkSession.tscn")# Temporary change to get_tree().change_scene("res://scenes/FromWorkToHome.tscn")
