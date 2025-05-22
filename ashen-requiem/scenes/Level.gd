extends Node

func _ready():
	var fader = get_node("UI/Fader")
	fader.modulate.a = 1.0
	call_deferred("_fade_in_from_black", fader)

	var player = get_node("MainCharacter")
	player.died.connect(_on_Player_died)

func _fade_in_from_black(fader):
	await fader.fade_out()

func _on_Player_died():
	var fader = get_node("UI/Fader")
	var game_over_menu = get_node("UI/GameOverMenu")

	await fader.fade_in()
	game_over_menu.visible = true
	
func fade_to_memory(scene_path: String):
	var fader = get_node("UI/Fader")
	await fader.fade_in()
	get_tree().change_scene_to_file(scene_path)
