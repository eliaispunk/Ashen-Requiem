extends ColorRect

@export var fade_time := 0.5

func fade_out() -> void:
	var tw = get_tree().create_tween()
	tw.tween_property(self, "modulate:a", 1.0, fade_time)
	await tw.finished

func fade_in() -> void:
	var tw = get_tree().create_tween()
	tw.tween_property(self, "modulate:a", 0.0, fade_time)
	await tw.finished
