extends Control

func _ready():
	if Engine.is_editor_hint():
		print("Running inside editor → skip resolution change.")
		return

	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	
	if err == OK:
		# Load volume
		var volume = config.get_value("audio", "master_volume", -40)
		$NinePatchRect/VBoxContainer/MasterVolumeSlider.value = volume
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volume)

		# Load fullscreen mode index
		var mode_index = config.get_value("display", "fullscreen_mode_index", 0)
		$NinePatchRect/VBoxContainer/FullscreenModeOptionButton.select(mode_index)
		if mode_index == 1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

		# Load resolution
		var resolutions = [
			Vector2i(1280, 720),
			Vector2i(1600, 900),
			Vector2i(1920, 1080)
		]
		var res_index = config.get_value("display", "resolution_index", 1)
		res_index = clamp(res_index, 0, resolutions.size() - 1)
		$NinePatchRect/VBoxContainer/ResolutionOptionButton.select(res_index)
		DisplayServer.window_set_size(resolutions[res_index])

		# Recenter window
		var screen_size = DisplayServer.screen_get_size()
		var window_size = DisplayServer.window_get_size()
		var center_position = (screen_size - window_size) / 2
		DisplayServer.window_set_position(center_position)

func _on_MasterVolumeSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)
	save_settings()

func _on_FullscreenModeOptionButton_item_selected(index):
	if index == 1:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	save_settings()

func _on_ResolutionOptionButton_item_selected(index):
	var resolutions = [
		Vector2i(1280, 720),
		Vector2i(1600, 900),
		Vector2i(1920, 1080)
	]
	DisplayServer.window_set_size(resolutions[index])

	# Recenter window after resolution change
	var screen_size = DisplayServer.screen_get_size()
	var window_size = DisplayServer.window_get_size()
	var center_position = (screen_size - window_size) / 2
	DisplayServer.window_set_position(center_position)

	save_settings()

func _on_BackButton_pressed():
	visible = false
	get_parent().get_node("GameOverMenu").visible = true

func save_settings():
	var config = ConfigFile.new()
	config.set_value("audio", "master_volume", $NinePatchRect/VBoxContainer/MasterVolumeSlider.value)
	config.set_value("display", "fullscreen_mode_index", $NinePatchRect/VBoxContainer/FullscreenModeOptionButton.selected)
	config.set_value("display", "resolution_index", $NinePatchRect/VBoxContainer/ResolutionOptionButton.selected)
	config.save("user://settings.cfg")
	print("Settings auto-saved.")
