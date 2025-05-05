extends Node

func _ready():
	var player = get_node("MainCharacter")
	player.died.connect(_on_Player_died)

func _on_Player_died():
	print("Fading to black...")
	var fader = get_node("UI/Fader")
	await fader.fade_out()
	get_tree().reload_current_scene()
	await fader.fade_in()
