extends Area2D

func _on_FallArea_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		get_tree().call_deferred("change_scene_to_file", "res://scenes/main.tscn")
