extends CanvasLayer

var is_paused := false

@onready var pause_dimmer = $PauseDimmer
@onready var game_over = $GameOverMenu
@onready var options_menu = $OptionsMenu

signal pause_toggled(paused: bool)

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if options_menu.visible:
			return

		if game_over.visible:
			game_over.visible = false
			pause_dimmer.visible = false
			get_tree().paused = false
			is_paused = false
		else:
			game_over.visible = true
			pause_dimmer.visible = true
			get_tree().paused = true
			is_paused = true

		emit_signal("pause_toggled", is_paused)
