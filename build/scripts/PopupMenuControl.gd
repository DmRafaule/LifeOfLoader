extends Control

var isCredits = false
var isSettings = false
var isMusic = false
var isSound = false
var isVoice = false
var popUps = ["openHelp","PressInfo","RochlaInfo","BoxAndCommonInfo","Rules"]
onready var session  = get_node("/root/Session")
var currentPopUp = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Next_pressed():
	$SoundCommonB.play(0.10)
	get_tree().get_root().get_node("WorkSession/blur").visible = false
	get_tree().get_root().get_node("WorkSession/EndDay").paused = false
	get_tree().get_root().get_node("WorkSession").isEndDay = false
	get_tree().get_root().get_node("WorkSession/Building/mch/Camera2D/HUD/ControlInterface").visible = true
	var node =	get_tree().get_root().get_node("WorkSession/Building/mch/Camera2D/HUD/PopupMenu")
	get_tree().get_root().get_node("WorkSession/Building/mch/Camera2D/HUD").remove_child(node) 


func _on_Exit_pressed():
	$SoundCommonB.play(0.10)
	get_tree().change_scene("res://scenes/Main.tscn")


func _on_Settings_pressed():
	$SoundCommonB.play(0.10)
	if (isSettings):
		isSettings = false
		get_node("AnimationPlayer").play_backwards("openSettings")
	else:
		isSettings = true
		if (session.isMutedSound):
			var newNorm = load("res://textures/hud/sound_muted.png")
			$SettingsP/Sound/soundB.normal = newNorm
		else:
			var newNorm = load("res://textures/hud/sound.png")
			$SettingsP/Sound/soundB.normal = newNorm
		if (session.isMutedMusic):
			var newNorm = load("res://textures/hud/music_muted.png")
			$SettingsP/Music/musicB.normal = newNorm
		else:
			var newNorm = load("res://textures/hud/music.png")
			$SettingsP/Music/musicB.normal = newNorm
		if (session.isMutedVoice):
			var newNorm = load("res://textures/hud/voice_muted.png")
			$SettingsP/Voice/voiceB.normal = newNorm
		else:
			var newNorm = load("res://textures/hud/voice.png")
			$SettingsP/Voice/voiceB.normal = newNorm
		get_node("AnimationPlayer").play("openSettings")
func _on_Credits_pressed():
	$SoundCommonB.play(0.10)
	if (isCredits):
		isCredits = false
		currentPopUp = 0
		get_node("AnimationPlayer").play_backwards("openHelp")
	else:
		isCredits = true
		get_node("AnimationPlayer").play("openHelp")



func _on_TouchScreenButton_pressed():
	$SoundCommonB.play(0.10)
	if (!get_node("AnimationPlayer").is_playing()):
		currentPopUp += 1
		get_node("AnimationPlayer").play(popUps[currentPopUp])


func _on_TouchScreenButton2_pressed():
	$SoundCommonB.play(0.10)
	if (!get_node("AnimationPlayer").is_playing()):
		get_node("AnimationPlayer").play_backwards(popUps[currentPopUp])
		currentPopUp -= 1



func _on_soundB_pressed():
	$SoundCommonB.play(0.10)
	if (!isSound):
		isSound = true
		var newNorm = load("res://textures/hud/sound_muted.png")
		$SettingsP/Sound/soundB.normal = newNorm
	else:
		isSound = false
		var newNorm = load("res://textures/hud/sound.png")
		$SettingsP/Sound/soundB.normal = newNorm
	session.isMutedSound = isSound


func _on_musicB_pressed():
	$SoundCommonB.play(0.10)
	if (!isMusic):
		isMusic = true
		var newNorm = load("res://textures/hud/music_muted.png")
		$SettingsP/Music/musicB.normal = newNorm
		get_tree().get_root().get_node("WorkSession/Ambient").stop()
		get_tree().get_root().get_node("WorkSession/Wind").stop()
	else:
		isMusic = false
		var newNorm = load("res://textures/hud/music.png")
		$SettingsP/Music/musicB.normal = newNorm
		get_tree().get_root().get_node("WorkSession/Ambient").play()
		get_tree().get_root().get_node("WorkSession/Wind").play()
	session.isMutedMusic = isMusic

func _on_voiceB_pressed():
	$SoundCommonB.volume_db = session.volumeVoice
	$SoundCommonB.play(0.10)
	if (!isVoice):
		isVoice = true
		var newNorm = load("res://textures/hud/voice_muted.png")
		$SettingsP/Voice/voiceB.normal = newNorm
		$SettingsP/Voice/voiceS.editable = false
		session.volumeVoice = $SettingsP/Voice/voiceS.min_value
		$SettingsP/Voice/voiceS.value = session.volumeVoice
	else:
		isVoice = false
		var newNorm = load("res://textures/hud/voice.png")
		$SettingsP/Voice/voiceB.normal = newNorm
		$SettingsP/Voice/voiceS.editable = true
		session.volumeVoice = 0
		$SettingsP/Voice/voiceS.value = 0
	session.isMutedVoice = isVoice
