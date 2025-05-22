extends Control

signal resume_requested  # 🔔 Signal for resuming the game

func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_options_button_pressed() -> void:
	get_parent().get_node("OptionsMenu").visible = true
	self.visible = false

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	get_parent().get_node("PauseDimmer").visible = false
	self.visible = false
	get_parent().is_paused = false
