extends Control
var resultDict : Dictionary = {
	"selling" 		: "",# Check
	"isClean" 		: "",# Check
	"isLightOff" 	: "",# Check
	"isInShop" 		: "",# Check
	"isSorted"      : "",# check
	"isHelped"		: "",# check
}
var recalculated : Dictionary = {
	"isClean" 	 	: "",
	"isLightOff" 	: "",
	"isInShop" 		: "",
	"isSorted" 		: "",
	"isHelped" 		: "",
}
var cashDay = ""
func _ready():
	get_node("AnimationPlayer").play("popuping")
	get_node("Results/RichTextLabel0").text = resultDict["selling"]
	
	get_node("Results/RichTextLabel1").text = resultDict["isClean"]
	if resultDict["isClean"] == "Yes":
		get_node("Results/RichTextLabel1").set_modulate(Color.greenyellow)
		recalculated["isClean"] = "+3$"
	else:
		get_node("Results/RichTextLabel1").set_modulate(Color.red)
		recalculated["isClean"] = "0$"
	
	get_node("Results/RichTextLabel2").text = resultDict["isLightOff"]
	if resultDict["isLightOff"] == "Yes":
		get_node("Results/RichTextLabel2").set_modulate(Color.greenyellow)
		recalculated["isLightOff"] = "+2$"
	else:
		get_node("Results/RichTextLabel2").set_modulate(Color.red)
		recalculated["isLightOff"] = "0$"
	
	get_node("Results/RichTextLabel6").text = resultDict["isInShop"]
	if resultDict["isInShop"] == "Yes":
		get_node("Results/RichTextLabel6").set_modulate(Color.greenyellow)
		recalculated["isInShop"] = "0$"
	else:
		get_node("Results/RichTextLabel6").set_modulate(Color.red)
		recalculated["isInShop"] = "-15$"
	
	get_node("Results/RichTextLabel7").text = resultDict["isSorted"]
	if resultDict["isSorted"] == "Perfect":
		get_node("Results/RichTextLabel7").set_modulate(Color.greenyellow)
		recalculated["isSorted"] = "+3$"
	elif resultDict["isSorted"] == "Kind of":
		get_node("Results/RichTextLabel7").set_modulate(Color.greenyellow)
		recalculated["isSorted"] = "+1$"
	elif resultDict["isSorted"] == "Not realy":
		get_node("Results/RichTextLabel7").set_modulate(Color.yellow)
		recalculated["isSorted"] = "0$"
	elif resultDict["isSorted"] == "Mess":
		get_node("Results/RichTextLabel7").set_modulate(Color.brown)
		recalculated["isSorted"] = "-5$"
	elif resultDict["isSorted"] == "What are you doing":
		get_node("Results/RichTextLabel7").set_modulate(Color.red)
		recalculated["isSorted"] = "-15$"
		
		
	get_node("Results/RichTextLabel8").text = resultDict["isHelped"]


func _on_Exit_pressed():
	get_tree().change_scene("res://scenes/Main.tscn")


func _on_Next_pressed():
	get_node("AnimationPlayer").play("disappearing")



func _on_AnimationPlayer_animation_finished(anim_name):
	match(anim_name):
		"disappearing":
			get_tree().change_scene("res://scenes/FromWorkToHome.tscn")
		"popuping":
			get_node("AnimationPlayer").play("recalculate")
			
			get_node("Results/RichTextLabel1").visible_characters = 0
			get_node("Results/RichTextLabel2").visible_characters = 0
			get_node("Results/RichTextLabel6").visible_characters = 0
			get_node("Results/RichTextLabel7").visible_characters = 0
			get_node("Results/RichTextLabel8").visible_characters = 0
			
			get_node("Results/RichTextLabel1").text = recalculated["isClean"]
			get_node("Results/RichTextLabel2").text = recalculated["isLightOff"]
			get_node("Results/RichTextLabel6").text = recalculated["isInShop"]
			get_node("Results/RichTextLabel7").text = recalculated["isSorted"]
			get_node("Results/RichTextLabel8").text = recalculated["isHelped"]
		"recalculate":
			if int(cashDay) >= 0:
				get_node("sumDay").set_modulate(Color.greenyellow)
			else:
				get_node("sumDay").set_modulate(Color.red)
			get_node("sumDay").text = cashDay + "$"
			get_node("AnimationPlayer").play("itog")
			
