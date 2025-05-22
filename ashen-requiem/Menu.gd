extends Control

@onready var fader: ColorRect = $Fader

var resolutions = [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080)
]

func _ready() -> void:
	# Safety check for Fader
	if fader:
		fader.mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		push_warning("Fader node not found — fade effects may not work.")

	# Load saved settings
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")

	var mode_index := 0
	var res_index := 1
	var volume := -15.0

	if err == OK:
		mode_index = config.get_value("display", "fullscreen_mode_index", 0)
		res_index = clamp(config.get_value("display", "resolution_index", 1), 0, resolutions.size() - 1)
		volume = config.get_value("audio", "master_volume_db", -15.0)
	else:
		print("No settings file found or failed to load.")

	_apply_display_settings(mode_index, res_index)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volume)

	# Start fully faded in, then fade out into scene
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

func _apply_display_settings(mode_index: int, res_index: int) -> void:
	# Apply screen mode
	if mode_index == 1:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

	# Apply resolution
	var size = resolutions[res_index]
	DisplayServer.window_set_size(size)

	# Center window in windowed mode
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		var screen_size = DisplayServer.screen_get_size()
		var window_size = DisplayServer.window_get_size()
		var center_position = (screen_size - window_size) / 2
		DisplayServer.window_set_position(center_position)
