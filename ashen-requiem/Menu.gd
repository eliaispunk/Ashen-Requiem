extends Control

@onready var fader: ColorRect = $Fader

func _ready() -> void:
	fader.mouse_filter = Control.MOUSE_FILTER_IGNORE  # optional safety

func _on_start_button_pressed() -> void:
	if fader:
		await fader.fade_in()
	get_tree().change_scene_to_file("res://scenes/dialogue1.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_options_button_pressed() -> void:
	pass
