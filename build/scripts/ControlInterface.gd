extends Control

export (int) var speed = 200
export (int) var g = 1
export (int) var touchBoxSize = 50
export (int) var touchPlayerSize = 100

var velocity = Vector2()
var controlingNode

var isDrag = false
var isJump = false
var currentIntObj = null
var currentGoodie = null
var interactableObjs
var hoursLeft = 11
var counter = 0

#Create goodie using his name and how many of them
func createGoodie(var name, var number):
	for i in range(0,number):
		var res = load("res://scenes/goodies/" + (str(name).replace(".png","")) + ".tscn").instance()
		res.isOpend = true
		res.add_to_group("save")
		res.nameGoodie = name
		res.nameStr = "goodie"
		res.position = currentGoodie.get_parent().position + currentGoodie.position + Vector2(0-i*20,-20 + i*3)
		get_tree().get_root().get_node("WorkSession").goodies.push_back(res)
		get_tree().get_root().get_node("WorkSession/Building").add_child(res)
#Create block (when enough empty boxes in press
func createBlock():
	var res = load("res://scenes/boxes/block.tscn").instance()
	var script = load("res://scripts/ExtendBodyPh.gd")
	res.set_script(script)
	currentIntObj.get_node("../press_counter/counter").text = str(currentIntObj.boxesCounter)
	res.position = get_tree().get_root().get_node("WorkSession/Building/press").position + Vector2(0,50)
	res.isOpend = true
	get_tree().get_root().get_node("WorkSession/Building").add_child(res)
	get_tree().get_root().get_node("WorkSession").goodies.push_back(res)
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
#This one used for droping box(deleting join)
func switchIntForc():
	if (!currentGoodie.isInteractable):
		currentGoodie.isInteractable = true
	else:
		currentGoodie.isInteractable = false	
func getInfo():
	if get_node("Popup").visible == false:
		get_node("Popup").popup()
		get_node("Popup/nameGoodie").text = str(currentGoodie.nameGoodie).replace(".png","")
		get_node("Popup/numberOfGoodie").text = str(currentGoodie.numberOfGoodie)
		get_node("Popup/AnimationPlayer").play("appearance")
	else:
		get_node("Popup").hide()
func dropBox():
	if (currentGoodie != null):
		get_node("DropBox/AnimationPlayer").play("GUI")
		get_node("DropBox/AnimationPlayer").play_backwards("appearance")
		get_node("OpenBox/AnimationPlayer").play_backwards("appearance")
		controlingNode.remove_child(controlingNode.get_node("joint"))
		currentGoodie.call_deferred("switchColl",false)
		currentGoodie.isInteractable = false
		# Set z index to default
		currentGoodie.z_index = 2
		currentGoodie = null
		isDrag = false
func openBox():
	get_node("Popup").hide()
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
func updateSessionTimer(delta):
	counter += delta
	get_node("Timer/min").text = str(int(get_tree().get_root().get_node("WorkSession/EndDay").time_left) % 60)
	if (int(get_tree().get_root().get_node("WorkSession/EndDay").time_left) % 60 == 0 and counter >= 1 and hoursLeft > 0):
		hoursLeft -= 1
		counter = 0
		get_node("Timer/hour").text = str(hoursLeft)
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
	# Then check all boxes
	elif (grab_zona.has_point(touchPoint)):
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
				currentGoodie.pos = controlingNode.get_position() + Vector2(20,0)
				box.isInteractable = true
		for g in get_tree().get_root().get_node("WorkSession").goodies:
			var item_zona = Rect2(Vector2(g.position.x - touchBoxSize/2,g.position.y - touchBoxSize/2),Vector2(touchBoxSize,touchBoxSize));
			g.rect = item_zona
			if item_zona.has_point(touchPoint):
				if currentGoodie != null:
					dropBox()
				get_node("DropBox/AnimationPlayer").play("appearance")
				currentGoodie = g
				currentGoodie.call_deferred("switchColl",true)
				currentGoodie.pos = controlingNode.get_position() + Vector2(20,0)
				g.isInteractable = true
				g.z_index = 4				
func onTouchRelease(event):
	if isDrag == true:
		dropBox()

func _on_ToRight_pressed():
	get_node("ToRight/AnimationPlayer").play("GUI")
	velocity.x += 1 
	velocity.x *= speed
	if (!currentGoodie == null):
		currentGoodie.pos = controlingNode.get_position() + Vector2(20,0)
		switchIntForc()
func _on_ToRight_released():
	velocity.x = 0
	
func _on_ToLeft_pressed():
	get_node("ToLeft/AnimationPlayer").play("GUI")
	velocity.x -= 1 
	velocity.x *= speed
	if (!currentGoodie == null):
		currentGoodie.pos = controlingNode.get_position() + Vector2(-40,0)
		switchIntForc()
func _on_ToLeft_released():
	velocity.x = 0

func _on_Jump_pressed():
	get_node("Jump/AnimationPlayer").play("GUI")
	if (!isJump):
		get_node("Jump/Timer").start()
		velocity.y = -7
		velocity.y *= speed
		isJump = true
		controlingNode.set_collision_mask_bit(1,true);
func _on_FallDown_pressed():
	get_node("FallDown/AnimationPlayer").play("GUI")
	velocity.y = 7
	velocity.y *= speed
	controlingNode.set_collision_mask_bit(1,false);

func _on_PopUpMenu_pressed():
	get_node("PopUpMenu/AnimationPlayer").play("GUI")
	
func _on_PressUp_pressed():
	if (currentIntObj.get_node("AnimatedSprite").is_playing()):
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
	getInfo()
func _on_InPress_pressed():
	if (currentGoodie != null and currentIntObj.boxesCounter < currentIntObj.maxCapacity):
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
	isJump = false
