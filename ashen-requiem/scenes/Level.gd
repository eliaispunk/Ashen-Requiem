extends Node

func _ready():
	# Fade from black at scene start
	var fader = get_node("UI/Fader")
	fader.modulate.a = 1.0                     # Start fully black
	call_deferred("_fade_in_from_black", fader)

	# Usual connection for player death
	var player = get_node("MainCharacter")
	player.died.connect(_on_Player_died)

func _fade_in_from_black(fader):
	await fader.fade_out()                     # Fade to transparent (show scene)

func _on_Player_died():
	print("Fading to black and showing Game Over menu...")
	var fader = get_node("UI/Fader")
	var game_over_menu = get_node("UI/GameOverMenu")

	await fader.fade_in()                      # Fade to black
	game_over_menu.visible = true
	
func fade_to_memory(scene_path: String):
	var fader = get_node("UI/Fader")
	await fader.fade_in()  # Fade to black
	get_tree().change_scene_to_file(scene_path)
