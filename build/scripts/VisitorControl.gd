extends Node2D

var deathTime
var isExit
var isStart
var sum = 0
var isInteractable = false
var text
var spr
var puff = preload("res://scenes/Puph.tscn")
var que  = preload("res://textures/humanEnviroment/question.png")

func setInter():
	isInteractable = true
	spr = Sprite.new()
	spr.texture = que
	spr.set_name("question")
	spr.position = get_node("Position2D").position
	add_child(spr)
func remove_question():
	remove_child(spr)
func say(var sentence):
	var res = load("res://scenes/Popup.tscn").instance()
	add_child(res)
	res.scale = Vector2(2,2)
	res.get_node("Sprite").visible = false
	res.get_node("Sprite2").visible = false
	res.get_node("Sprite3").visible = false
	get_node("Popup/RichTextLabel").text = sentence
	get_node("Sprite").play("talk")
func createPuff(var pos):
	var res = puff.instance()
	res.position = pos
	res.scale = Vector2(3,3)
	get_tree().get_root().get_node("WorkSession/Building").add_child(res)
func take():
	var rnd    = RandomNumberGenerator.new()	
	rnd.randomize()
	if get_tree().get_nodes_in_group("goodies").size() > 0:
		var g = get_tree().get_nodes_in_group("goodies")[rnd.randi_range(0,get_tree().get_nodes_in_group("goodies").size()-1)]
		if !g.isInteractable:
			sum += 10
			createPuff(g.position)
			get_tree().get_root().get_node("WorkSession/Building").remove_child(g)
			
func partol():
	var rnd    = RandomNumberGenerator.new()	
	rnd.randomize()
	var x = rnd.randi_range(-600,700)
	if (position.x < x):
		get_node("Sprite").play("walk")
		get_node("Sprite").flip_h = false
	else:
		get_node("Sprite").play("walk")
		get_node("Sprite").flip_h = true
	get_node("Sprite").speed_scale = rnd.randf_range(0.8,1.5)
	get_node("Tween").interpolate_property(self,"position",self.position,Vector2(x,self.position.y),5,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	get_node("Tween").start()
	if (rnd.randi_range(0,30) == 1):	
		take()


func exit():
	isExit = true
	var rnd    = RandomNumberGenerator.new()	
	rnd.randomize()
	get_node("Sprite").flip_h = true
	get_node("Sprite").play("walk")
	get_node("Tween").interpolate_property(get_node("."),"position",self.position, Vector2(-1000,self.position.y),5,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	get_node("Tween").start()
func enter():
	isStart = true
	var rnd    = RandomNumberGenerator.new()	
	rnd.randomize()
	get_node("Sprite").flip_h = false
	get_node("Sprite").play("walk")
	get_node("Sprite").speed_scale = rnd.randf_range(0.8,1.5)
	get_node("Tween").interpolate_property(get_node("."),"position",self.position,self.position + Vector2(400,0),rnd.randf_range(1.5,2.0),Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	get_node("Tween").start()
func _ready():
	
	enter()
	
func self_kill():
	self.remove_child(get_node("Sprite"))
	self.remove_child(get_node("Tween"))
	self.remove_child(get_node("Position2D"))
	self.remove_child(get_node("PositionForTouch"))
	self.remove_child(get_node("AnimationPlayer"))
	remove_and_skip()


func _on_Tween_tween_all_completed():
	if (isExit):
		#HERE animation of $555 on cassier
		self_kill()
	elif (isStart):
		partol()
