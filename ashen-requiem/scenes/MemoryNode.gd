extends Area2D

@onready var prompt = $Panel
var player_in_range = false

func _ready():
	prompt.visible = false
	set_monitoring(true)

func _on_body_entered(body):
	if body.is_in_group("players"):
		prompt.visible = true
		body.nearby_memory = self

func _on_body_exited(body):
	if body.is_in_group("players"):
		prompt.visible = false
		if body.nearby_memory == self:
			body.nearby_memory = null

func collect():
	var level = get_tree().current_scene
	if level.has_method("fade_to_memory"):
		level.fade_to_memory("res://scenes/dialogue_memory1.tscn")
