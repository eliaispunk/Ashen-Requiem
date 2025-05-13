extends Area2D

func _on_FallArea_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.has_signal("died"):
		body.emit_signal("died")
