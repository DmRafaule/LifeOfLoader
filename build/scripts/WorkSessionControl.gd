extends Node2D

var events = [] # Contain all events(functions) to execute

onready var session  = get_node("/root/Session") # Get access to global script property such as current day(for loading and saving)
onready var boxP = get_node("Building/boxes") # Contain parent node for all boxes
var left_dialogWin = 0
var sum_result = 0
var isListMatch = false
var isEndDay = false # Used for disable ability enable visible GUI control in ConrolInterface.gd
var numTask = 0
var closedTask = 0

var savePath : String= "user://save.txt" # Where to save 

# Save all nodes in group "save" in savePath
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
# Load all nodes in group "save" if file already exist (not new game) overwise random generate new boxes and goodies
func loading():
	var file = File.new()
	if file.file_exists(savePath):	
		file.open(savePath,file.READ)
		var counterBox = 0		
		while file.get_position() < file.get_len():
			var data = parse_json(file.get_line())
			if (data["name"] == "day" ):
				loadDayScript("day" + data["current_day"])
				session.current_day = str2var(data["current_day"])
			# If yesterday was a free day partition randomize
			if (session.month[session.current_day - 1] == "free"):
				var rnd    = RandomNumberGenerator.new()	
				rnd.randomize()
				match(str2var(data["name"])):
					"box":
						if (rnd.randi_range(0,100) >= 50):
							createBox(str2var(data["type"]),str2var(data["position"]),str2var(data["content"]),str2var(data["num"]),str2var(data["isOpend"]))
					"goodie":
						if (rnd.randi_range(0,100) >= 50):
							createGoodie(str2var(data["position"]),str2var(data["content"]),1)
					"platform":
						get_tree().get_root().get_node("WorkSession/Building/platform").set_position(str2var(data["position"]))
					"press":
						get_tree().get_root().get_node("WorkSession/Building/press_counter/counter").text = str(data["box_counter"])
						get_tree().get_root().get_node("WorkSession/Building/press").boxesCounter = str2var(data["box_counter"])
			# Else yesterday was a work day -> no randomize
			else:
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
		file.close()
	else:# First day(new game) - > full randomie
		var rnd    = RandomNumberGenerator.new()	
		rnd.randomize()
		# Spawn rect for boxes
		var sSRect = Rect2(Vector2(825,200),Vector2(330,330));
		# Spawn rect for goodies
		var TZRect = Rect2(Vector2(-550,300),Vector2(1200,130));
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

		loadDayScript("day1")

# Load all timing functions to proccesGameEvents
# Form file
func loadDayScript(var name):
	var file = File.new()
	if (file.file_exists("res://dayScripts/" + name + ".tres")):
		file.open("res://dayScripts/" + name + ".tres",file.READ)
		while file.get_position() < file.get_len():
			var data = parse_json(file.get_line())
			events.append({
				"name" : str2var(data["name"]),
				"executionHour" : str2var(data["executionHour"]),
				"executionMin" : str2var(data["executionMin"]),
				"properties" : str2var(data["properties"]),
			})
		file.close()
# Used for defining when to start dialog and what of dialog to start
func startDialog(var dayname):
	session.isDialogStart = true
	get_node("Building/mch/Camera2D/HUD/ControlInterface").visible = false
	get_node("Building/mch/AnimationPlayer").play("StartDialog")
	var file = File.new()
	if file.file_exists("res://dayDialog/" + dayname + ".tres"):
		file.open("res://dayDialog/" + dayname + ".tres",file.READ)
		while file.get_position() < file.get_len():
			var data = parse_json(file.get_line())
			session.dialogs.append({
				"properties" : [data["text"],data["who"]]
			})
		file.close()
		# First dialog win start here
		callv("createDialogWin",session.dialogs[session.current_dialog_win]["properties"])
		session.current_dialog_win += 1
# For create dialog window
func createDialogWin(var text, var forWho):
	var res = load("res://scenes/Popup.tscn").instance()
	var HUD = get_node_or_null("Building/" + forWho)
	if (HUD != null):
		res.get_node("Sprite").visible = false
		HUD.add_child(res)
		HUD.get_node("Popup/RichTextLabel").text = text
# Create dialog win for random visitor
func createDialogWinForVisitors(var text, var forWho):
	var res = load("res://scenes/Popup.tscn").instance()
	var arr = []
	var rnd    = RandomNumberGenerator.new()	
	rnd.randomize()
	for node in get_node("Building/visitors").get_children():
		arr.append(node.name)
	var HUD = get_node_or_null("Building/" + forWho + "/" + arr[rnd.randi_range(0,arr.size()-1)])
	if (HUD != null):
		HUD.add_child(res)
		res.scale = Vector2(2,2)
		res.get_node("Sprite").visible = false
		res.get_node("Sprite2").visible = false
		res.get_node("Sprite3").visible = false
		HUD.get_node("Popup/RichTextLabel").text = text
# This func used only if you intendent close dialog early than it supposed to be
func removeDialogWin(var forWho):
	var HUD = get_node_or_null("Building/" + forWho + "/Popup")
	if (HUD != null):
		HUD.hide()
# Set task to this visitor
func setTask(var name):
	var arr = []
	var rnd    = RandomNumberGenerator.new()	
	rnd.randomize()
	for node in get_node("Building/visitors").get_children():
		arr.append(node.name)
	var visitor = get_node_or_null("Building/visitors/" + arr[rnd.randi_range(0,arr.size()-1)])
	if (visitor != null):
		numTask += 1
		visitor.setInter()
		visitor.text = name
		

func createVisitor(var size):
	for i in range(0,size):
		var rnd    = RandomNumberGenerator.new()	
		rnd.randomize()
		var types = ["low","medium","tall"]
		var res = load("res://scenes/characters/visitor_" + str(types[rnd.randi_range(0,2)]) + ".tscn").instance()
		res.set_position(Vector2(-850,res.position.y))
		res.z_index = rnd.randi_range(2,5)
		# Run animation for intering
		# Set when he will left
		res.deathTime = session.current_hour - rnd.randi_range(2,4)
	
		get_node("Building/visitors").add_child(res)
		res.enter()
		# Set event when he will left
		events.append({
			"name" : "removeVisitor",
			"executionHour" : res.deathTime,
			"executionMin" :  0,
			"properties" : [res],
		})
func removeVisitor(var visitor):
	sum_result += visitor.sum
	visitor.exit()
func createGoodie(var pos, var name, var number):
	for i in range(0,number):
		var res = load("res://scenes/goodies/" + (str(name).replace(".png","")) + ".tscn").instance()
		res.add_to_group("save")
		res.add_to_group("goodies")
		res.setBoxGoodie(name,1)
		res.nameStr = "goodie"
		res.isOpend = true
		res.position = pos
		get_tree().get_root().get_node("WorkSession/Building").add_child(res)
func createBox(var type, var pos, var content, var num, var isOpend = false):
	var box = load("res://scenes/boxes/box" + type + ".tscn").instance()
	box.add_to_group("save")
	box.add_to_group("boxes")
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
func createTruck(var numTray):
	var res = load("res://scenes/trucks/WorkingTruck.tscn").instance()
	
	res.set_position(Vector2(1514,190))
	get_node("Building").call_deferred("add_child",res)
	# Here implement box loading and tray
	for i in range(0,numTray):
		res.createTray(res.get_node("main/Position" + str(i)).position)
func removeTruck():
	get_node("Building").call_deferred("remove_child",get_node("Building/Truck"))
# Read all images in texture/goodies and return array of strings(names of goodies)
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
# Execute all setted functions to events array(Used in ControlInterface.gd when timer reached predefinde time(hours))
func proccesseGameEvents(var current_hour, var current_minutes):
	for event in events:
		if (current_minutes == event.executionMin):
			if (current_hour == event.executionHour):
				callv(event.name,event.properties)

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

# Check if goodies or boxes of platform out the shop
func inTheShop(var res):
	var isInShop = true
	if get_node("Building/platform").position.x > 1250:
		isInShop = false
	for b in get_tree().get_nodes_in_group("boxes"):
		if (b.position + b.get_parent().position).x > 1250:
			isInShop = false
	for g in get_tree().get_nodes_in_group("goodies"):
		if g.position.x > 1250:
			isInShop = false
	if isInShop:
		res.resultDict["isInShop"] = "Yes"
	else: 
		res.resultDict["isInShop"] = "No"
# Check if goodie on the floor and if boxes in TZ
func isClean(var res):
	var isClean = true
	for b in get_tree().get_nodes_in_group("boxes"):
		if (b.position + b.get_parent().position).x < 750:# Some boxes in Trande hole
			isClean = false
		elif b.nameGoodie == "empty box":# There is left some empty boxes
			isClean = false
	for g in get_tree().get_nodes_in_group("goodies"):
		if g.position.y > 500:#Goodie on the floor
			isClean = false
	
	if isClean:
		res.resultDict["isClean"] = "Yes"
	else: 
		res.resultDict["isClean"] = "No"
# Check if lights off
func isLightOff(var res):
	var switch = get_node("Building/switch")
	if switch.isLightOn:
		res.resultDict["isLightOff"] = "No"
	else:
		res.resultDict["isLightOff"] = "Yes"
# Check if goodie in right place 
func isSorted(var res):
	var howManyNotInRightPlace = 0
	var howManyInRightPlace = 0
	var rect
	for g in get_tree().get_nodes_in_group("goodies"):
		match g.typeGoodie:#Goodie on the floor
			"toy":
				rect = Rect2(Vector2(-375,260),Vector2(200,300))
				if rect.has_point(g.position):
					howManyInRightPlace += 1
				else:
					howManyNotInRightPlace += 1
			"utencil":
				rect = Rect2(Vector2(425,260),Vector2(250,300))
				if rect.has_point(g.position):
					howManyInRightPlace += 1
				else:
					howManyNotInRightPlace += 1
			"chemistry":
				rect = Rect2(Vector2(-175,260),Vector2(200,300))
				if rect.has_point(g.position):
					howManyInRightPlace += 1
				else:
					howManyNotInRightPlace += 1
			"office":
				rect = Rect2(Vector2(100,260),Vector2(330,300))
				if rect.has_point(g.position):
					howManyInRightPlace += 1
				else:
					howManyNotInRightPlace += 1
			"food":
				rect = Rect2(Vector2(-575,260),Vector2(200,300))
				if rect.has_point(g.position):
					howManyInRightPlace += 1
				else:
					howManyNotInRightPlace += 1
					
	if howManyNotInRightPlace == 0:
		res.resultDict["isSorted"] = "Perfect"
	else:
		var out = howManyInRightPlace/howManyNotInRightPlace
		if out == 1:
			res.resultDict["isSorted"] = "Not realy"
		elif out > 1 and out <= 2:
			res.resultDict["isSorted"] = "Kind of"
		elif out < 1 and out >= 0.5:
			res.resultDict["isSorted"] = "Mess"
		elif out < 0.5:
			res.resultDict["isSorted"] = "What are you doing"
func isHelped(var res):
	res.resultDict["isHelped"] = str(closedTask) + "/" + str(numTask)
func _on_EndDay_timeout():
	saving()
	isEndDay = true
	var res = load("res://scenes/Results.tscn").instance()
	res.resultDict["selling"] = str(sum_result/20) + "$"
	inTheShop(res)
	isClean(res)
	isLightOff(res)
	isSorted(res)
	isHelped(res)
	get_tree().get_root().get_node("WorkSession/Building/mch/Camera2D/HUD").add_child(res)
	get_node("Building/mch/Camera2D/HUD/ControlInterface").visible = false
	# ADD animation of fading out for BG 
	# ADD animation for fading in for Result popup
	modulate = Color(0.06,0.06,0.06,1.0) 
	
