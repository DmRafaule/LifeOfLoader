extends Node2D

var events = [] # Contain all events(functions) to execute
var goo = {} # Contain all preload goodies types
var bo0 = preload("res://scenes/boxes/box0.tscn")
var bo1 = preload("res://scenes/boxes/box1.tscn")
var bo2 = preload("res://scenes/boxes/box2.tscn")
var bo3 = preload("res://scenes/boxes/box3.tscn")
var bo4 = preload("res://scenes/boxes/box4.tscn")
var bo5 = preload("res://scenes/boxes/box5.tscn")
var bo6 = preload("res://scenes/boxes/box6.tscn")


onready var session  = get_node("/root/Session") # Get access to global script property such as current day(for loading and saving)
onready var boxP = get_node("Building/boxes") # Contain parent node for all boxes
var left_dialogWin = 0
var sum_result = 0
var isListMatch = false
var isEndDay = false # Used for disable ability enable visible GUI control in ConrolInterface.gd
var numTask = 0
var closedTask = 0
var cashDay = 0

var savePath : String= "user://save.txt" # Where to save 

# (INTERNAL) Save all nodes in group "save" in savePath
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
	var cash : Dictionary = {
		"name"			: "cash",
		"cash"			: var2str(session.cash)
	}
	file.store_line(to_json(cash))
	var mistakes : Dictionary = {
		"name"			: "mistake",
		"mistake_count" : var2str(session.lethalMistakes)
	}
	file.store_line(to_json(mistakes))
	file.close()
# (INTERNAL) Load all nodes in group "save" if file already exist (not new game) overwise random generate new boxes and goodies
func loading():
	var file = File.new()
	if file.file_exists(savePath):	
		file.open(savePath,file.READ)
		var counterBox = 0		
		while file.get_position() < file.get_len():
			var data = parse_json(file.get_line())
			match(str2var(data["name"])):
				"day":
					session.current_day = str2var(data["current_day"])
					# This check exist only for one reason if player exit from game when he go to home or in "free day" what is almouste impossible
					# I will redirect them to next working day
					if session.month[session.current_day] == "free":
						if session.month[session.current_day+1] == "free":
							session.current_day += 2
						else:
							session.current_day += 1
					loadDayScript("day" + str(session.current_day))
					showDayName(str(session.current_day))
				"cash":
					session.cash = str2var(data["cash"])
				"mistake":
					session.lethalMistakes = str2var(data["mistake_count"])
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

		loadDayScript("day9")
# (INTERNAL) Load all timing functions to proccesGameEvents Form file
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
# (INTERNAL) popup day name
func showDayName(var num):
	var res = load("res://scenes/dayNumber.tscn").instance()
	match(num):
		"2":
			res.get_node("digit").texture = load("res://textures/hud/two.png")
			res.get_node("tens")
		"5":
			res.get_node("digit").texture = load("res://textures/hud/five.png")
			res.get_node("tens")
		"6":
			res.get_node("digit").texture = load("res://textures/hud/six.png")
			res.get_node("tens")
		"9":
			res.get_node("digit").texture = load("res://textures/hud/nine.png")
			res.get_node("tens")
		"10":
			res.get_node("digit").texture = load("res://textures/hud/zero.png")
			res.get_node("tens").texture = load("res://textures/hud/one.png")
		"13":
			res.get_node("digit").texture = load("res://textures/hud/three.png")
			res.get_node("tens").texture = load("res://textures/hud/one.png")
		"14":
			res.get_node("digit").texture = load("res://textures/hud/four.png")
			res.get_node("tens").texture = load("res://textures/hud/one.png")
		"17":
			res.get_node("digit").texture = load("res://textures/hud/seven.png")
			res.get_node("tens").texture = load("res://textures/hud/one.png")
		"18":
			res.get_node("digit").texture = load("res://textures/hud/eight.png")
			res.get_node("tens").texture = load("res://textures/hud/one.png")
		"21":
			res.get_node("digit").texture = load("res://textures/hud/one.png")
			res.get_node("tens").texture = load("res://textures/hud/two.png")
		"22":
			res.get_node("digit").texture = load("res://textures/hud/two.png")
			res.get_node("tens").texture = load("res://textures/hud/two.png")
		"25":
			res.get_node("digit").texture = load("res://textures/hud/five.png")
			res.get_node("tens").texture = load("res://textures/hud/two.png")
		"26":
			res.get_node("digit").texture = load("res://textures/hud/six.png")
			res.get_node("tens").texture = load("res://textures/hud/two.png")
		"29":
			res.get_node("digit").texture = load("res://textures/hud/nine.png")
			res.get_node("tens").texture = load("res://textures/hud/two.png")
		"30":
			res.get_node("digit").texture = load("res://textures/hud/zero.png")
			res.get_node("tens").texture = load("res://textures/hud/three.png")
	get_node("Building/mch/Camera2D/HUD").add_child(res)
# (EXTERNAL) Used for defining when to start dialog and what of dialog to start(for defining end by fired)
func startDialogResultCheck():
	session.isDialogStart = true
	get_node("Building/mch/Camera2D/HUD/ControlInterface").visible = false
	get_node("Building/mch/AnimationPlayer").play("StartDialog")
	var file = File.new()
	var dialog
	match (session.lethalMistakes):
		0:
			dialog = "res://dayDialog/breathing.tres"
		1,2,3:
			dialog = "res://dayDialog/warning.tres"
		4:
			dialog = "res://dayDialog/last_warning.tres"
		5:
			dialog = "res://dayDialog/dismissal.tres" # Fired here
	if file.file_exists(dialog):
		file.open(dialog,file.READ)
		while file.get_position() < file.get_len():
			var data = parse_json(file.get_line())
			session.dialogs.append({
				"properties" : [data["text"],data["who"],data["pos"],data["spead"]]
			})
			# set all needed characters near by mch
			if (data["who"] != "mch" and !session.setCharacters.has(data["who"]) ):
				call_deferred("setCharacterNearByForDialog",data["who"])
		file.close()
		# First dialog win start here
		call_deferred("createDialogWinForEmployee",session.dialogs[session.current_dialog_win]["properties"][0],
													session.dialogs[session.current_dialog_win]["properties"][1])
		session.current_dialog_win += 1
# (EXTERNAL) used only after startDialogResultCheck() and in the 30 day fon opening right scene of end game
func theEnd():
	pass
# (EXTERNAL) Used for defining when to start dialog and what of dialog to start
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
				"properties" : [data["text"],data["who"],data["pos"],data["spead"]]
			})
			# set all needed characters near by mch
			if (data["who"] != "mch" and !session.setCharacters.has(data["who"]) ):
				call_deferred("setCharacterNearByForDialog",data["who"])
		file.close()
		# First dialog win start here
		call_deferred("createDialogWinForEmployee",session.dialogs[session.current_dialog_win]["properties"][0],
													session.dialogs[session.current_dialog_win]["properties"][1])
		session.current_dialog_win += 1
# (INTERNAL) For create dialog window
func createDialogWinForEmployee(var text, var forWho):
	var res = session.pp.instance()
	res.type = "Employee"
	var HUD = get_node_or_null("Building/" + forWho)
	if (HUD != null):
		res.get_node("Sprite").visible = false
		HUD.add_child(res)
		HUD.get_node("Popup/RichTextLabel").text = text
# (EXTERNAL) Create dialog win for random visitor
func createDialogWinForVisitors(var text, var forWho):
	var res = session.pp.instance()
	var arr = []
	var rnd    = RandomNumberGenerator.new()	
	rnd.randomize()
	res.type = "Vis"
	for node in get_node("Building/visitors").get_children():
		arr.append(node.name)
	if (arr.size() != 0):
		var HUD = get_node_or_null("Building/" + forWho + "/" + arr[rnd.randi_range(0,arr.size()-1)])
		if (HUD != null):
			HUD.add_child(res)
			res.scale = Vector2(2,2)
			res.get_node("Sprite").visible = false
			res.get_node("Sprite2").visible = false
			res.get_node("Sprite3").visible = false
			HUD.get_node("Popup/RichTextLabel").text = text
# (INTERNAL) This func used only if you intendent close dialog early than it supposed to be
func removeDialogWin(var forWho):
	var HUD = get_node_or_null("Building/" + forWho + "/Popup")
	if (HUD != null):
		HUD.hide()
# (EXTERNAL) Set task to this visitor
func setTask(var name):
	var arr = []
	var rnd    = RandomNumberGenerator.new()	
	rnd.randomize()
	for node in get_node("Building/visitors").get_children():
		arr.append(node.name)
	var dT = 0
	var iI = true
	var visitor
	while dT <= 1 and iI:
		visitor = get_node_or_null("Building/visitors/" + arr[rnd.randi_range(0,arr.size()-1)])
		if (visitor != null):
			iI = visitor.isInteractable
			dT = visitor.deathTime
	numTask += 1
	visitor.setInter()
	visitor.text = name
# (EXTERNAL) Create character for current day
func setCharacter(var name, var position, var animation):
	var character = load("res://scenes/characters/" + name + ".tscn").instance()
	character.position = position
	character.get_node("AnimationPlayer").play(animation)
	session.setCharacters.append({
		"name" : name,
		"firstPlAnim" : animation,
		"defaultPos" : position,
	})
	get_node("Building").add_child(character)
# (EXTERNAL) Move to new position
func moveCharacter(var name, var position, var spead):
	var character = get_node("Building/" + name)
	if (character != null):
		character.walk_to(position,spead)
func jumpCharacter(var name, var position):
	var character = get_node("Building/" + name)
	character.position = position
# (EXTERNAL) Remove from scene
func unSetCharacter(var name, var position):
	var character = get_node("Building/" + name)
	if (character != null):
		character.leave(position)
# (INTERNAL) Prepare character for dialog
func setCharacterNearByForDialog(var forWho):
	var rnd    = RandomNumberGenerator.new()	
	rnd.randomize()
	var character = get_node_or_null("Building/" + forWho)
	if (character.position.x < get_node("Building/mch").position.x):
		if (character.position.x <= get_node("Building/mch").position.x - 800):
			character.position.x = get_node("Building/mch").position.x - 800
		character.get_node("Tween").interpolate_property(character,"position:x",character.position.x,get_node("Building/mch").position.x - rnd.randi_range(60,120),2,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
		character.get_node("Tween").start()
	else:
		if (character.position.x >= get_node("Building/mch").position.x + 800):
			character.position.x = get_node("Building/mch").position.x + 800
		character.get_node("Tween").interpolate_property(character,"position:x",character.position.x,get_node("Building/mch").position.x + rnd.randi_range(60,120),2,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
		character.get_node("Tween").start()
	if (get_node("Building/mch").position.x > 1250):
		character.position.y = 514
	character.get_node("AnimationPlayer").play("walk")
# (INTERNAL) move character to needed position
func setCharacterMovement(var forWho, var pos , var spead : float):
	if pos != "null":
		pos = str2var(pos)
		var character = get_node_or_null("Building/" + forWho)
		character.get_node("Tween").interpolate_property(character,"position:x",character.position.x,pos.x,abs(pos.x/spead),Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
		character.get_node("Tween").start()
# (EXTERNAL) create a bunch of rnd visitors and define their death time
func createVisitor(var size):
	for i in range(0,size):
		var rnd    = RandomNumberGenerator.new()	
		rnd.randomize()
		var types = ["low","medium","tall"]
		var res
		match (str(types[rnd.randi_range(0,2)])):
			"low":
				res = session.v_l.instance()
			"medium":
				res = session.v_m.instance()
			"tall":
				res = session.v_t.instance()
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
# (INTERNAL) remove chosen visitor
func removeVisitor(var visitor):
	sum_result += visitor.sum
	visitor.exit()
# (INTERNAL) create a bunch of goodies
func createGoodie(var pos, var name, var number):
	for i in range(0,number):
		var res = goo[name].instance()
		res.add_to_group("save")
		res.add_to_group("goodies")
		res.setBoxGoodie(name,1)
		res.nameStr = "goodie"
		res.isOpend = true
		res.position = pos
		get_tree().get_root().get_node("WorkSession/Building").add_child(res)
# (INTERNAL) create a box
func createBox(var type, var pos, var content, var num, var isOpend = false):
	var box
	match (type):
		"0":
			box = bo0.instance()
		"1":
			box = bo1.instance()
		"2":
			box = bo2.instance()
		"3":
			box = bo3.instance()
		"4":
			box = bo4.instance()
		"5":
			box = bo5.instance()
		"6":
			box = bo6.instance()
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
# (EXTERNAL) create the truck with specified num of trayes
func createTruck(var numTray):
	var res = load("res://scenes/trucks/WorkingTruck.tscn").instance()
	
	res.set_position(Vector2(1514,190))
	get_node("Building").call_deferred("add_child",res)
	# Here implement box loading and tray
	for i in range(0,numTray):
		res.createTray(res.get_node("main/Position" + str(i)).position)
# (EXTERNAL) play animation of leaving and prepare for die
func removeTruck():
	get_node("Building/Truck").isEnd = true
	get_node("Building/Truck/main/platform").remove_child(get_node("Building/Truck/main/platform/Area2D"))
	get_node("Building/Truck/AnimationPlayer").play_backwards("platform_active")
# (INTERNAL) Read all images in texture/goodies and return array of strings(names of goodies)
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
# (INTERNAL) Execute all setted functions to events array(Used in ControlInterface.gd when timer reached predefinde time(hours))
func proccesseGameEvents(var current_hour, var current_minutes):
	for event in events:
		if (current_minutes == event.executionMin):
			if (current_hour == event.executionHour):
				callv(event.name,event.properties)
# (INTERNAL) Preload all goodies types
func preloadGoodies():
	var files = getAllTypesOfGoodies()
	for f in files:
		var path = "res://scenes/goodies/" + (str(f).replace(".png","")) + ".tscn"
		goo[f] = load(path)

func _ready():
	preloadGoodies()
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
		session.cash += 0
		cashDay += 0
	else: 
		res.resultDict["isInShop"] = "No"
		session.cash -= 15
		cashDay -= 15
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
		session.cash += 3
		cashDay += 3
	else: 
		res.resultDict["isClean"] = "No"
		session.cash += 0
		cashDay += 0
# Check if lights off
func isLightOff(var res):
	var switch = get_node("Building/switch")
	if switch.isLightOn:
		res.resultDict["isLightOff"] = "No"
		session.cash += 0
		cashDay += 0
	else:
		res.resultDict["isLightOff"] = "Yes"
		session.cash += 2
		cashDay += 2
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
		session.cash += 3
		cashDay += 3
	else:
		var out = howManyInRightPlace/howManyNotInRightPlace
		if out == 1:
			res.resultDict["isSorted"] = "Not realy"
			session.cash += 1
			cashDay += 1
		elif out > 1 and out <= 2:
			res.resultDict["isSorted"] = "Kind of"
			session.cash += 0
			cashDay += 0 
		elif out < 1 and out >= 0.5:
			res.resultDict["isSorted"] = "Mess"
			session.cash -= 5
			cashDay -= 5
		elif out < 0.5:
			res.resultDict["isSorted"] = "What are you doing"
			session.cash -= 15
			cashDay -= 15
# Count how many times do you help
func isHelped(var res):
	res.resultDict["isHelped"] = str(closedTask) + "/" + str(numTask)
	res.recalculated["isHelped"] = "+"+str(closedTask)+"$"
	session.cash += closedTask
	cashDay += closedTask
# Check if player actualy worked
func isWorking(var res):
	var amountOfGoodies = get_tree().get_nodes_in_group("goodies").size()
	var amountOfBoxes   = get_tree().get_nodes_in_group("boxes").size()
	if (amountOfBoxes > 0):
		if (amountOfGoodies/amountOfBoxes <= 0.1):
			session.lethalMistakes += 1
func _on_EndDay_timeout():
	isEndDay = true
	var res = load("res://scenes/Results.tscn").instance()
	res.resultDict["selling"] = str(sum_result/20) + "$"
	session.cash += sum_result/20
	session.setCharacters.clear()
	cashDay += sum_result/20
	inTheShop(res)
	isClean(res)
	isLightOff(res)
	isSorted(res)
	isHelped(res)
	isWorking(res)
	res.cashDay = str(cashDay)
	if (cashDay <= -15):
		session.lethalMistakes += 1
	saving()
	
	get_tree().get_root().get_node("WorkSession/Building/mch/Camera2D/HUD").add_child(res)
	get_node("Building/mch/Camera2D/HUD/ControlInterface").visible = false
	modulate = Color(0.06,0.06,0.06,1.0) 
	
