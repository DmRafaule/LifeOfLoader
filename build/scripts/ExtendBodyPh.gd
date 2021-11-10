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
var numberOfGoodie = 0

func setBoxGoodie(var name, var number):
	nameGoodie = name
	numberOfGoodie = number

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
