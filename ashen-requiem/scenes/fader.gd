extends ColorRect

@export var fade_time := 1

func fade_out() -> void:
	# Correct: fade to transparent (scene becomes visible)
	if not is_inside_tree():
		await ready
	var tw = get_tree().create_tween()
	tw.tween_property(self, "modulate:a", 0.0, fade_time)
	await tw.finished

func fade_in() -> void:
	# Correct: fade to black (screen becomes black)
	if not is_inside_tree():
		await ready
	var tw = get_tree().create_tween()
	tw.tween_property(self, "modulate:a", 1.0, fade_time)
	await tw.finished
