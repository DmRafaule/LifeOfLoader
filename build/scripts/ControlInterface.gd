extends Control

export (int) var speed = 200
export (int) var g = 1
export (int) var touchBoxSize = 50
export (int) var touchPlayerSize = 100

onready var session  = get_node("/root/Session") 

var velocity = Vector2()
var controlingNode

var isDrag = false
var isJump = false
var currentIntObj = null
var currentGoodie = null
var interactableObjs
var prevMinsLeft = 60
var minsLeft  = 59
var hoursLeft = 11
var counter = 0

#Create goodie using his name and how many of them
func createGoodie(var name, var number):
	for i in range(0,number):
		var res = get_tree().get_root().get_node("WorkSession").goo[name].instance()
		res.isOpend = true
		res.add_to_group("save")
		res.add_to_group("goodies")
		res.setBoxGoodie(name,1)
		res.nameStr = "goodie"
		res.position = currentGoodie.get_parent().position + currentGoodie.position + Vector2(0-i*20,-20 + i*3)
		get_tree().get_root().get_node("WorkSession/Building").add_child(res)
#Create block (when enough empty boxes in press
func createBlock():
	var res = load("res://scenes/boxes/block.tscn").instance()
	var script = load("res://scripts/ExtendBodyPh.gd")
	res.set_script(script)
	res.add_to_group("goodies")
	currentIntObj.get_node("../press_counter/counter").text = str(currentIntObj.boxesCounter)
	res.position = get_tree().get_root().get_node("WorkSession/Building/press").position + Vector2(0,50)
	res.isOpend = true
	get_tree().get_root().get_node("WorkSession/Building").add_child(res)
	res.setBoxGoodie("block",1)
#Create fix join bettween nodeA and NodeB where join will be child of NodeA
func createJoin(var nodeA, var nodeB):
	var joint = PinJoint2D.new()
	joint.set_name("joint")
	joint.set_position(nodeA.position)
	joint.set_node_a(NodePath(nodeA.get_path()))
	joint.set_node_b(NodePath(nodeB.get_path()))
	joint.set_softness(2)
	nodeA.add_child(joint)
func createPuff(var pos):
	var res = load("res://scenes/Puph.tscn").instance()
	res.position = pos
	res.scale = Vector2(3,3)
	get_tree().get_root().get_node("WorkSession/Building").add_child(res)
#This one used for droping box(deleting join)
func switchIntForc():
	if (!currentGoodie.isInteractable):
		currentGoodie.isInteractable = true
	else:
		currentGoodie.isInteractable = false	
func getInfo():
	if get_node("Popup").visible == false:
		get_node("Popup").popup()
		get_node("Popup/borders").visible = true
		get_node("Popup/nameGoodie").text = str(currentGoodie.nameGoodie).replace(".png","")
		get_node("Popup/numberOfGoodie").text = str(currentGoodie.numberOfGoodie)
		get_node("Popup/AnimationPlayer").play("appearance")
	else:
		get_node("Popup").hide()
func getInfoList():
	if get_node("Popup").visible == false:
		get_node("Popup").popup()
		get_node("Popup/borders").visible = false
		get_node("Popup/nameGoodie").text = str(currentGoodie.nameGoodie).replace(".png","")
		get_node("Popup/numberOfGoodie").text = ""
		get_node("Popup/AnimationPlayer").play("appearance")
	else:
		get_node("Popup/borders").visible = true
		get_node("Popup").hide()
func dropBox():
	if (currentGoodie != null):
		get_node("DropBox/AnimationPlayer").play("GUI")
		get_node("DropBox/AnimationPlayer").play_backwards("appearance")
		get_node("OpenBox/AnimationPlayer").play_backwards("appearance")
		var j = controlingNode.get_node_or_null("joint")
		if (j != null):
			controlingNode.remove_child(j)
		currentGoodie.get_node("Sprite").material = null
		currentGoodie.call_deferred("switchColl",false)
		currentGoodie.isInteractable = false
		# Set z index to default
		currentGoodie.z_index = 2
		currentGoodie = null
		isDrag = false
func openBox():
	get_node("Popup").hide()
	var eff = get_tree().get_root().get_node("WorkSession").openEff.instance()
	get_tree().get_root().get_node("WorkSession/Building/mch/AnimationPlayer").play("openBox")
	get_tree().get_root().get_node("WorkSession/Building/mch").add_child(eff)
	currentGoodie.isOpend = true
	createGoodie(currentGoodie.nameGoodie,currentGoodie.numberOfGoodie)
	currentGoodie.nameGoodie = "empty box"
	currentGoodie.numberOfGoodie = 0
	get_node("OpenBox/AnimationPlayer").play("GUI")
	# Set up new sprite and correcting boundary for CollisionShape2D
	var previousHeight = currentGoodie.get_node("Sprite").get_rect().size.y
	var newImageForBox :StreamTexture = load("res://textures/boxes/box_opened" + str(currentGoodie.boxType) + ".png")
	currentGoodie.get_node("Sprite").texture = newImageForBox
	var newHeight = currentGoodie.get_node("Sprite").get_rect().size.y
	currentGoodie.get_node("CollisionShape2D").position += Vector2(0,(newHeight - previousHeight)/2 )
func dragBox(event):
	if currentGoodie != null and currentGoodie.rect.has_point(touchScreenPositionToGlobal(event.position,controlingNode)) :
		var size = controlingNode.get_node("GrabArea/CollisionShape2D").shape.extents * 4
		var grab_zona   = Rect2(Vector2(controlingNode.position.x - size.x/2,controlingNode.position.y - size.y/1.5),size)
		if (grab_zona.has_point(touchScreenPositionToGlobal(event.position,controlingNode))):
			currentGoodie.call_deferred("switchColl",false)
			isDrag = true
			currentGoodie.pos = touchScreenPositionToGlobal(event.position,controlingNode)
			currentGoodie.rect.position = Vector2(currentGoodie.pos.x - touchBoxSize/2,currentGoodie.pos.y - touchBoxSize/2)
			switchIntForc()
func dayLightUpdate():
	get_tree().get_root().get_node("WorkSession/BG").modulate -= Color(0.07,0.07,0.07,0.0)
	get_tree().get_root().get_node("WorkSession/BG/lighters/ligherAtStreet1/Light2D").energy += 0.17
	get_tree().get_root().get_node("WorkSession/BG/lighters/ligherAtStreet2/Light2D").energy += 0.17
	get_tree().get_root().get_node("WorkSession/BG/lighters/ligherAtStreet3/Light2D").energy += 0.17
	get_tree().get_root().get_node("WorkSession/BG/lighters/ligherAtStreet4/Light2D").energy += 0.17
	get_tree().get_root().get_node("WorkSession/BG/lighters/ligherAtStreet5/Light2D").energy += 0.17
	
func updateSessionTimer(delta):
	counter += delta
	minsLeft = int(get_tree().get_root().get_node("WorkSession/EndDay").time_left) % 60
	if (prevMinsLeft != minsLeft):
		get_node("Timer/min").text = str(minsLeft)		
		# Execute script events (such as truck appearance or massive attack of clients
		get_tree().get_root().get_node("WorkSession").proccesseGameEvents(hoursLeft,minsLeft)
	prevMinsLeft = minsLeft
	if (int(get_tree().get_root().get_node("WorkSession/EndDay").time_left) % 60 == 0 and counter >= 1 and hoursLeft > 0):
		dayLightUpdate()
		hoursLeft -= 1
		session.current_hour = hoursLeft
		counter = 0
		get_node("Timer/hour").text = str(hoursLeft)
	# Update dialog, called only then if previose was destroid
	if (session.isEndPhrase):
		session.isEndPhrase = false
		var ws = get_tree().get_root().get_node_or_null("WorkSession")
		ws.get_node("Building/mch/AnimatedSprite").play("idle")# stop talking animation
		if (session.current_dialog_win < session.dialogs.size()):
			ws.createDialogWinForEmployee(session.dialogs[session.current_dialog_win]["properties"][0],
											session.dialogs[session.current_dialog_win]["properties"][1])
			ws.setCharacterMovement(session.dialogs[session.current_dialog_win]["properties"][1],
									session.dialogs[session.current_dialog_win]["properties"][2],
									str2var(session.dialogs[session.current_dialog_win]["properties"][3]))
			session.current_dialog_win += 1
		else:
			ws.get_node("Building/mch/Camera2D/HUD/ControlInterface").visible = true
			if (session.isDialogStart):
				session.isDialogStart = false
				ws.get_node("Building/mch/AnimationPlayer").play_backwards("StartDialog")
#This function need point which to transform and node which need to get transformation delay
func touchScreenPositionToGlobal(point,canvasNode):
	#Get transformation our canvas layer(HUD)
	var canvas_transform = canvasNode.get_canvas_transform().get_origin()
	#Get how mush transformation have done
	return point - canvas_transform

func _ready():
	controlingNode = get_tree().get_root().get_node("WorkSession/Building/mch")
	# Main node for all interactable objects
	interactableObjs = get_tree().get_nodes_in_group("forPlayerInt")

	
func _process(delta):
	updateSessionTimer(delta)	
func _physics_process(delta):
	if (velocity.y < g):
		velocity.y += g
	elif (velocity.y > g):
		velocity.y -= g
	controlingNode.move_and_slide(velocity)	


func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			onTouchPressed(event)
		else:
			onTouchRelease(event)
	if event is InputEventScreenDrag :
		dragBox(event)
func onTouchPressed(event):
	interactableObjs = get_tree().get_nodes_in_group("forPlayerInt")
	var touchPoint = touchScreenPositionToGlobal(event.position,controlingNode)
	# First of all check if we touch the player "touching box"
	var size = controlingNode.get_node("CollisionShape2D").shape.extents * 4
	var player_zona = Rect2(Vector2(controlingNode.position.x - size.x/2,controlingNode.position.y - size.y/2),size)
	size = controlingNode.get_node("GrabArea/CollisionShape2D").shape.extents * 4
	var grab_zona   = Rect2(Vector2(controlingNode.position.x - size.x/2,controlingNode.position.y - size.y/1.5),size+Vector2(10,10))
	if (player_zona.has_point(touchPoint)):
		# If this obj is interactable (because he is in a radius of player)
		for iObj in interactableObjs:
			# If this object is a platform we will create pinjoin for dyn interaction and two buttoms for lifting and falling
			if (iObj.isInteractable and iObj.nameStr == "platform"):
				var joint = PinJoint2D.new()
				currentIntObj = iObj
				if (!currentIntObj.isUnderControl):
					joint.set_name("pinjoint2d")
					joint.set_node_a(NodePath(controlingNode.get_path()))
					joint.set_node_b(NodePath(currentIntObj.get_path()))
					joint.set_softness(3.5)
					joint.set_position(Vector2(-37.442,-2.071))
					currentIntObj.add_child(joint)
					get_node("LiftUpPlatform/AnimationPlayer").play("appearance")
					get_node("LiftDownPlatform/AnimationPlayer").play("appearance")
					currentIntObj.isUnderControl = true
				else:
					currentIntObj.remove_child(currentIntObj.get_node(NodePath("./pinjoint2d")))
					get_node("LiftUpPlatform/AnimationPlayer").play_backwards("appearance")
					get_node("LiftDownPlatform/AnimationPlayer").play_backwards("appearance")
					currentIntObj.isUnderControl = false
					currentIntObj = null
			elif(iObj.isInteractable and iObj.nameStr == "press"):
				currentIntObj = iObj
				currentIntObj.buttonsObj.push_back(get_node("PressDown/AnimationPlayer"))
				currentIntObj.buttonsObj.push_back(get_node("PressUp/AnimationPlayer"))
				currentIntObj.buttonsObj.push_back(get_node("PressUp/AnimationPlayer"))
				if(currentIntObj.isInteractable):
					get_node("PressDown/AnimationPlayer").play("appearance")
					get_node("PressUp/AnimationPlayer").play("appearance")
					if (currentGoodie != null):
						get_node("DropBox/AnimationPlayer").play_backwards("appearance")
						get_node("OpenBox/AnimationPlayer").play_backwards("appearance")
						currentIntObj.buttonsObj.push_back(get_node("DropBox/AnimationPlayer"))
						currentIntObj.buttonsObj.push_back(get_node("OpenBox/AnimationPlayer"))
						if (currentGoodie.isOpend == true):
							currentIntObj.buttonsObj.push_back(get_node("InPress/AnimationPlayer"))
							get_node("InPress/AnimationPlayer").play("appearance")
					currentIntObj.isInteractable = false
					
				else:	
					get_node("PressDown/AnimationPlayer").play_backwards("appearance")
					get_node("PressUp/AnimationPlayer").play_backwards("appearance")
					if (currentGoodie != null):
						get_node("DropBox/AnimationPlayer").play("appearance")
						get_node("OpenBox/AnimationPlayer").play("appearance")
						if (currentGoodie.isOpend == true):
							get_node("InPress/AnimationPlayer").play_backwards("appearance")
					currentIntObj.isInteractable = true
					currentIntObj = null
			elif(iObj.isInteractable and iObj.nameStr == "switch"):
				var m1 = get_tree().get_root().get_node("WorkSession/Building")
				var m2 = get_tree().get_root().get_node("WorkSession/BG")
				if get_tree().get_root().get_node("WorkSession/Building/buildingG/LightInShop1").enabled:
					m1.modulate = m2.modulate
				else:
					m1.modulate = Color(1.0,1.0,1.0,1.0)
				iObj.use(get_tree().get_root().get_node("WorkSession/Building/buildingG/LightInShop1"))
				iObj.use(get_tree().get_root().get_node("WorkSession/Building/buildingG/LightInShop2"))
				iObj.use(get_tree().get_root().get_node("WorkSession/Building/buildingG/LightInShop3"))
				iObj.use(get_tree().get_root().get_node("WorkSession/Building/buildingG/LightInStorage"))
			elif(iObj.isInteractable and iObj.nameStr == "tray"):
				iObj.open()
	# Then check all boxes
	if (grab_zona.has_point(touchPoint)):
		#Main node of all boxes
		var boxes = get_tree().get_nodes_in_group("boxes")
		#Position of node which contain all boxes(global)
		for box in boxes:
			var box_pos = box.get_parent().position + box.position 
			#Create temporary rect for detection
			var box_zona = Rect2(Vector2(box_pos.x - touchBoxSize/2,box_pos.y - touchBoxSize/2),Vector2(touchBoxSize,touchBoxSize))
			box.rect = box_zona 
			#Check if touch was in temporary rect
			if box_zona.has_point(touchPoint) and currentGoodie == null:
				get_node("DropBox/AnimationPlayer").play("appearance")
				get_node("OpenBox/AnimationPlayer").play("appearance")
				currentGoodie = box
				currentGoodie.call_deferred("switchColl",true)
				currentGoodie.pos = controlingNode.get_position() + Vector2(10,0)
				currentGoodie.z_index += 2
				if box.isInteractable:
					box.isInteractable = false
				else:
					box.isInteractable = true
				
		for g in get_tree().get_nodes_in_group("goodies"):
			var item_zona = Rect2(Vector2(g.position.x - touchBoxSize/2,g.position.y - touchBoxSize/2),Vector2(touchBoxSize,touchBoxSize));
			g.rect = item_zona
			if item_zona.has_point(touchPoint):
				if currentGoodie != null:
					dropBox()
				get_node("DropBox/AnimationPlayer").play("appearance")
				currentGoodie = g
				currentGoodie.call_deferred("switchColl",true)
				currentGoodie.pos = controlingNode.get_position() + Vector2(10,0)
				if g.isInteractable:
					g.isInteractable = false
				else:
					g.isInteractable = true
				g.z_index = 4
	# Skip dialog
	if (session.current_dialog_win <= session.dialogs.size() and session.current_dialog_win > 0):
		get_tree().get_root().get_node("WorkSession").removeDialogWin(session.dialogs[session.current_dialog_win - 1]["properties"][1])
	# Ask about task
	if (!session.isDialogStart):
		for v in get_tree().get_nodes_in_group("visitors"):
			var visitor_rect = Rect2(Vector2(v.position.x - 25,v.position.y - 50),Vector2(50,200))
			if visitor_rect.has_point(touchPoint) and v.isInteractable:
				# Compare
				if currentGoodie != null:
					if v.text == currentGoodie.nameGoodie.replace(".png",""):
						#HERE animation for puff and bying 
						v.say("That is it, I'll take it")
						get_tree().get_root().get_node("WorkSession").closedTask += 1
						v.createPuff(currentGoodie.position)
						v.remove_question()
						v.isInteractable = false
						v.sum += 15
						# Remove goodie
						get_node("DropBox/AnimationPlayer").play("GUI")
						get_node("DropBox/AnimationPlayer").play_backwards("appearance")
						get_node("OpenBox/AnimationPlayer").play_backwards("appearance")
						var j = controlingNode.get_node_or_null("joint")
						if (j != null):
							controlingNode.remove_child(j)
						get_tree().get_root().get_node("WorkSession/Building").remove_child(currentGoodie)
						currentGoodie = null
						isDrag = false
					else:
						v.say("What ??? No. I did say " + v.text)
				else:
					v.say("Mr. can you find me " + v.text)

func onTouchRelease(event):
	if isDrag == true:
		dropBox()

func _on_ToRight_pressed():
	get_node("ToRight/AnimationPlayer").play("GUI")
	get_tree().get_root().get_node("WorkSession/Building/mch/AnimatedSprite").flip_h = false
	get_tree().get_root().get_node("WorkSession/Building/mch/AnimatedSprite").play("run")
	velocity.x += 1 
	velocity.x *= speed
	if (!currentGoodie == null):
		get_tree().get_root().get_node("WorkSession/Building/mch/AnimatedSprite").flip_h = false
		get_tree().get_root().get_node("WorkSession/Building/mch/AnimatedSprite").play("runWithBox")
		currentGoodie.pos = controlingNode.get_position() + Vector2(30,-10)
		currentGoodie.get_node("Sprite").material = load("res://shaders/floatingGoodie.tres")
		switchIntForc()
	elif (currentIntObj != null and currentIntObj.nameStr == "platform"):
		get_tree().get_root().get_node("WorkSession/Building/mch/AnimatedSprite").flip_h = false
		get_tree().get_root().get_node("WorkSession/Building/mch/AnimatedSprite").play("runWithBox")
func _on_ToRight_released():
	get_tree().get_root().get_node("WorkSession/Building/mch/AnimatedSprite").flip_h = false
	get_tree().get_root().get_node("WorkSession/Building/mch/AnimatedSprite").play("idle")
	if (!currentGoodie == null):
		currentGoodie.isInteractable = true
		currentGoodie.get_node("Sprite").material = null
		currentGoodie.pos = controlingNode.get_position() + Vector2(0,0)
	velocity.x = 0
	
func _on_ToLeft_pressed():
	get_node("ToLeft/AnimationPlayer").play("GUI")
	get_tree().get_root().get_node("WorkSession/Building/mch/AnimatedSprite").flip_h = true
	get_tree().get_root().get_node("WorkSession/Building/mch/AnimatedSprite").play("run")
	velocity.x -= 1 
	velocity.x *= speed
	if (!currentGoodie == null):
		get_tree().get_root().get_node("WorkSession/Building/mch/AnimatedSprite").flip_h = true
		get_tree().get_root().get_node("WorkSession/Building/mch/AnimatedSprite").play("runWithBox")
		currentGoodie.pos = controlingNode.get_position() + Vector2(-50,-10)
		currentGoodie.get_node("Sprite").material = load("res://shaders/floatingGoodie.tres")
		switchIntForc()
	elif (currentIntObj != null and currentIntObj.nameStr == "platform"):
		get_tree().get_root().get_node("WorkSession/Building/mch/AnimatedSprite").flip_h = false
		get_tree().get_root().get_node("WorkSession/Building/mch/AnimatedSprite").play("runWithBox",true)
func _on_ToLeft_released():
	get_tree().get_root().get_node("WorkSession/Building/mch/AnimatedSprite").flip_h = false
	get_tree().get_root().get_node("WorkSession/Building/mch/AnimatedSprite").play("idle")
	if (!currentGoodie == null):
		currentGoodie.isInteractable = true
		currentGoodie.get_node("Sprite").material = null
		currentGoodie.pos = controlingNode.get_position() + Vector2(0,0)
	velocity.x = 0

func _on_Jump_pressed():
	get_node("Jump/AnimationPlayer").play("GUI")
	get_tree().get_root().get_node("WorkSession/Building/mch/AnimatedSprite").play("jump")
	if (!isJump):
		get_node("Jump/Timer").start()
		velocity.y = -7
		velocity.y *= speed
		isJump = true
		controlingNode.set_collision_mask_bit(1,true);
func _on_FallDown_pressed():
	get_node("Jump/Timer").start()
	get_node("FallDown/AnimationPlayer").play("GUI")
	get_tree().get_root().get_node("WorkSession/Building/mch/AnimatedSprite").play("fallFromSurf")
	velocity.y = 7
	velocity.y *= speed
	controlingNode.set_collision_mask_bit(1,false);

func _on_PopUpMenu_pressed():
	get_tree().get_root().get_node("WorkSession/EndDay").paused = true
	get_node("PopUpMenu/AnimationPlayer").play("GUI")
	get_tree().get_root().get_node("WorkSession").isEndDay = true
	var res = load("res://scenes/PopupMenu.tscn").instance()
	get_tree().get_root().get_node("WorkSession/Building/mch/Camera2D/HUD").add_child(res)
	get_tree().get_root().get_node("WorkSession/Building/mch/Camera2D/HUD/ControlInterface").visible = false
	get_tree().get_root().get_node("WorkSession").modulate = Color(0.06,0.06,0.06,1.0) 
	
func _on_PressUp_pressed():
	if (currentIntObj.get_node("AnimatedSprite").is_playing()):
		get_tree().get_root().get_node("WorkSession/Building/mch/AnimationPlayer").play("usingPress")
		get_node("PressUp/AnimationPlayer").play("GUI")
		currentIntObj.get_node("AnimatedSprite").play("pressing",true)
		if (currentIntObj.isStartCreatingBlock):
			currentIntObj.get_node("AnimatedSprite").play("openingBottom",false)
			currentIntObj.isStartCreatingBlock = false
			currentIntObj.blockCounter += 1
			currentIntObj.boxesCounter = 0
			createBlock()
func _on_PressDown_pressed():
	if (currentIntObj.get_node("AnimatedSprite").is_playing()):
		get_tree().get_root().get_node("WorkSession/Building/mch/AnimationPlayer").play("usingPress")
		get_node("PressDown/AnimationPlayer").play("GUI")
		currentIntObj.get_node("AnimatedSprite").play("pressing")
		if (currentIntObj.boxesCounter == currentIntObj.maxCapacity):
			currentIntObj.isStartCreatingBlock = true
func _on_LiftUpPlatform_pressed():
	get_node("LiftUpPlatform/AnimationPlayer").play("GUI")
	if (currentIntObj.liftCounter <= 2 && currentIntObj.liftCounter >= 0):
		currentIntObj.get_node("AnimationPlayer").play("lifting" + String(currentIntObj.liftCounter))
		if (currentIntObj.liftCounter != 2):
			currentIntObj.liftCounter+=1
func _on_LiftDownPlatform_pressed():
	get_node("LiftDownPlatform/AnimationPlayer").play("GUI")
	if (currentIntObj.liftCounter <= 2 && currentIntObj.liftCounter >= 0):
		currentIntObj.get_node("AnimationPlayer").play_backwards("lifting"+String(currentIntObj.liftCounter))
		if (currentIntObj.liftCounter != 0):
			currentIntObj.liftCounter-=1
func _on_OpenBox_pressed():
	if (!currentGoodie.isOpend):
		openBox()
		dropBox()
func _on_DropBox_pressed():
	if currentGoodie.nameStr == "list":
		getInfoList()
	else:
		getInfo()
func _on_InPress_pressed():
	if (currentGoodie != null and currentIntObj.boxesCounter < currentIntObj.maxCapacity and currentGoodie.nameGoodie != "block"):
		get_tree().get_root().get_node("WorkSession/Building/mch/AnimationPlayer").play("usingPress")
		createPuff(get_tree().get_root().get_node("WorkSession/Building/mch").position)
		currentIntObj.boxesCounter += 1
		currentIntObj.get_node("../press_counter/counter").text = str(currentIntObj.boxesCounter)
		get_node("DropBox/AnimationPlayer").play("GUI")
		get_node("DropBox/AnimationPlayer").play_backwards("appearance")
		get_node("OpenBox/AnimationPlayer").play_backwards("appearance")
		controlingNode.remove_child(controlingNode.get_node("joint"))
		currentGoodie.call_deferred("switchColl",false)
		currentGoodie.isInteractable = false
		currentIntObj.hideUI = true
		currentGoodie.get_parent().remove_child(currentGoodie)
		currentGoodie = null
		isDrag = false
# For jumping ability
func _on_Timer_timeout():
	if (get_tree().get_root().get_node("WorkSession/Building/mch/AnimatedSprite").animation == "jump"):
		get_tree().get_root().get_node("WorkSession/Building/mch/AnimatedSprite").play("idle")
	elif (get_tree().get_root().get_node("WorkSession/Building/mch/AnimatedSprite").animation == "fallFromSurf"):
		get_tree().get_root().get_node("WorkSession/Building/mch/AnimatedSprite").play("idle")
		
	isJump = false

