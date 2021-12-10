extends RigidBody2D
# This script provide additional physics to rigidbody2d. If be more accuracy, add telepotation and move ignoring physics

var isInteractable # Used in ControlInterface.gd, for makeing additional unphysical stuff
var isOpend = false # Used in ControlInterface.gd only for create goodie
var dirMod = Vector2(-20,0)
var pos = self.position
var cN
var rect
var z = z_index
var boxType

var nameStr
var nameGoodie = ""
var typeGoodie = "none"
var numberOfGoodie = 0

func setBoxGoodie(var name, var number):
	nameGoodie = name
	numberOfGoodie = number
	match(nameGoodie):
		"bunny.png","puzzles.png","soap_bubbles.png","puzzles_small.png","inflatable_ring.png","helicopter.png","doll.png","car.png","bear.png","ball.png":
			typeGoodie = "toy"
		"cymbals.png","Bowls.png","CimbalsSmall.png","Cups.png","jar.png","Teapot.png":
			typeGoodie = "utencil"
		"fairy.png","solid_soap_super.png","solid_soap_avtar.png","soap-powder_zebra.png","soap-powder_mur.png","soap-powder_aqu.png","soap-powder.png","liquid_Xpower.png","liquid_soap_for_kids.png","liquid_soap_b2.png","liquid_antifat.png","liquid_1004.png","bleach.png","anti-raid.png":
			typeGoodie = "chemistry"
		"notebooks.png","A4Paper.png","Covers.png","Markers.png","Pens.png","Pensil.png","SchoolNotebookObjects.png","SchoolNotebook.png":
			typeGoodie = "office"
		"pizza.png","tea_another.png","tea.png","seeds.png","Energizer.png","Crackers.png","coffee.png","Chips.png","Beer.png":
			typeGoodie = "food"

func _ready():
	isInteractable = false
	cN = get_tree().get_root().get_node("WorkSession/Building/mch")

func switchColl(var val):
	get_node("CollisionShape2D").disabled = val
func switchJoin():
	if sleeping == true:
		sleeping = false;
	else:
		sleeping = true;
	if (!cN.get_node_or_null("joint") == null):
		cN.remove_child(cN.get_node("joint"))
	var joint = PinJoint2D.new()
	joint.set_name("joint")
	joint.set_position(dirMod/2)
	joint.set_node_a(NodePath(cN.get_path()))
	joint.set_node_b(NodePath(self.get_path()))
	joint.set_softness(2)
	cN.add_child(joint)
	isInteractable = false

# This function used to be for making some unrealistics mose such as teleportation to player
func _integrate_forces(state):
	if (isInteractable):
		call_deferred("switchJoin")
		state.transform.origin = pos
	sleeping = false
