extends Node

func _ready():
	var player = get_node("MainCharacter")
	player.died.connect(_on_Player_died)

func _on_Player_died():
	print("Fading to black and showing Game Over menu...")
	var fader = get_node("UI/Fader")
	var game_over_menu = get_node("UI/GameOverMenu")
	
	await fader.fade_out()
	game_over_menu.visible = true
