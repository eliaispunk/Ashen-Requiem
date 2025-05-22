extends Control

var resolutions = [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080)
]

func _ready():
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")

	var mode_index := 0
	var res_index := 1
	var volume := -15.0

	if err == OK:
		mode_index = config.get_value("display", "fullscreen_mode_index", 0)
		res_index = clamp(config.get_value("display", "resolution_index", 1), 0, resolutions.size() - 1)
		volume = config.get_value("audio", "master_volume_db", -15.0)

	$Panel/VBoxContainer/FullscreenModeOptionButton.select(mode_index)
	$Panel/VBoxContainer/ResolutionOptionButton.select(res_index)
	$Panel/VBoxContainer/MasterVolumeSlider.value = volume

	_apply_display_settings(mode_index, res_index)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volume)

func _on_FullscreenModeOptionButton_item_selected(index):
	var res_index = $Panel/VBoxContainer/ResolutionOptionButton.selected
	_apply_display_settings(index, res_index)
	save_settings()

func _on_ResolutionOptionButton_item_selected(index):
	var mode_index = $Panel/VBoxContainer/FullscreenModeOptionButton.selected
	_apply_display_settings(mode_index, index)
	save_settings()

func _on_MasterVolumeSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)
	save_settings()

func _on_BackButton_pressed():
	visible = false
	get_parent().get_node("GameOverMenu").visible = true

func save_settings():
	var config = ConfigFile.new()
	config.set_value("display", "fullscreen_mode_index", $Panel/VBoxContainer/FullscreenModeOptionButton.selected)
	config.set_value("display", "resolution_index", $Panel/VBoxContainer/ResolutionOptionButton.selected)
	config.set_value("audio", "master_volume_db", $Panel/VBoxContainer/MasterVolumeSlider.value)
	config.save("user://settings.cfg")
	print("Settings auto-saved.")

func _apply_display_settings(mode_index: int, res_index: int):
	# Set screen mode
	if mode_index == 1:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

	# Set resolution (applied in both modes)
	var size = resolutions[res_index]
	DisplayServer.window_set_size(size)

	# Re-center window only in windowed mode
	if mode_index == 0:
		var screen_size = DisplayServer.screen_get_size()
		var window_size = DisplayServer.window_get_size()
		var center_position = (screen_size - window_size) / 2
		DisplayServer.window_set_position(center_position)
