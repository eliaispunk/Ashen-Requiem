extends RigidBody2D

var health := 1

func _ready():
	add_to_group("enemies")

func take_damage(amount: int):
	health -= amount
	if health <= 0:
		queue_free()  # Destroy the enemy
