extends CanvasLayer

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		var game_over = $GameOverMenu
		var options   = $OptionsMenu

		if options.visible:
			return

		if game_over.visible:
			game_over.visible = false
			get_tree().paused = false
		else:
			game_over.visible = true
			get_tree().paused = true
