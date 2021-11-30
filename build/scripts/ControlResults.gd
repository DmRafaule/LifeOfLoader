extends Control
var resultDict : Dictionary = {
	"selling" 		: "",# Check
	"isClean" 		: "",# Check
	"isLightOff" 	: "",# Check
	"isInShop" 		: "",# Check
	"isSorted"      : "",# ckeck
	"isHelped"		: ""
}

func _ready():
	# ADD animation of fading in for fields 
	# ADD animation of popup results fields
	# ADD animation for changing text from Yes/No to actual reward money
	# ADD animation for changing scene fading out then tap next or exit
	get_node("Results/RichTextLabel0").text = resultDict["selling"]
	
	get_node("Results/RichTextLabel1").text = resultDict["isClean"]
	if resultDict["isClean"] == "Yes":
		get_node("Results/RichTextLabel1").set_modulate(Color.greenyellow)
	else:
		get_node("Results/RichTextLabel1").set_modulate(Color.red)
	
	get_node("Results/RichTextLabel2").text = resultDict["isLightOff"]
	if resultDict["isLightOff"] == "Yes":
		get_node("Results/RichTextLabel2").set_modulate(Color.greenyellow)
	else:
		get_node("Results/RichTextLabel2").set_modulate(Color.red)
	
	get_node("Results/RichTextLabel6").text = resultDict["isInShop"]
	if resultDict["isInShop"] == "Yes":
		get_node("Results/RichTextLabel6").set_modulate(Color.greenyellow)
	else:
		get_node("Results/RichTextLabel6").set_modulate(Color.red)
	
	get_node("Results/RichTextLabel7").text = resultDict["isSorted"]
	if resultDict["isSorted"] == "Perfect":
		get_node("Results/RichTextLabel7").set_modulate(Color.greenyellow)
	elif resultDict["isSorted"] == "Kind of":
		get_node("Results/RichTextLabel7").set_modulate(Color.greenyellow)
	elif resultDict["isSorted"] == "Not realy":
		get_node("Results/RichTextLabel7").set_modulate(Color.yellow)
	elif resultDict["isSorted"] == "Mess":
		get_node("Results/RichTextLabel7").set_modulate(Color.brown)
	elif resultDict["isSorted"] == "What are you doing":
		get_node("Results/RichTextLabel7").set_modulate(Color.red)
		
	get_node("Results/RichTextLabel8").text = resultDict["isHelped"]


func _on_Exit_pressed():
	get_tree().change_scene("res://scenes/Main.tscn")


func _on_Next_pressed():
	get_tree().change_scene("res://scenes/FromWorkToHome.tscn")

