extends Control

func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_options_button_pressed() -> void:
	get_parent().get_node("OptionsMenu").visible = true
	self.visible = false

func _on_exit_button_pressed() -> void:
	get_tree().quit()
