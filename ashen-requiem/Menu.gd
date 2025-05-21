extends Control

@onready var fader: ColorRect = $Fader

func _ready() -> void:
	# Safety check for Fader
	if fader:
		fader.mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		push_warning("Fader node not found — fade effects may not work.")

	# Load saved settings
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err == OK:
		# Fullscreen mode
		var mode_index = config.get_value("display", "fullscreen_mode_index", 0)
		if mode_index == 1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

		# Resolution
		var resolutions = [
			Vector2i(1280, 720),
			Vector2i(1600, 900),
			Vector2i(1920, 1080)
		]
		var res_index = config.get_value("display", "resolution_index", 1)
		res_index = clamp(res_index, 0, resolutions.size() - 1)
		DisplayServer.window_set_size(resolutions[res_index])

		# Center window (only in windowed mode)
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
			var screen_size = DisplayServer.screen_get_size()
			var window_size = DisplayServer.window_get_size()
			var center_position = (screen_size - window_size) / 2
			DisplayServer.window_set_position(center_position)

		# Master volume
		var volume = config.get_value("audio", "master_volume_db", -15.0)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volume)
	else:
		print("No settings file found or failed to load.")
		
	if fader:
		fader.modulate.a = 1.0
		await fader.fade_out()

func _on_start_button_pressed() -> void:
	if fader:
		await fader.fade_in()
	get_tree().change_scene_to_file("res://scenes/dialogue1.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_options_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/option_mainmenu.tscn")
