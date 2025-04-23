extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -550.0
const GRAVITY = 1200.0
@onready var sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var is_attacking: bool = false

func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		if velocity.y > 0:
			velocity.y += GRAVITY * 1.3 * delta  # faster falling
		else:
			velocity.y += GRAVITY * delta

	# Handle attack input
	if Input.is_action_just_pressed("attack") and is_on_floor() and not is_attacking:
		is_attacking = true
		velocity.x = 0  # Stop horizontal movement immediately
		sprite_2d.play("attacking")
		return  # Skip further input this frame

	# Skip input while attacking (but still let gravity & move_and_slide run)
	if not is_attacking:
		# Handle jump
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Handle movement
		var direction := Input.get_axis("left", "right")
		if direction:
			velocity.x = direction * SPEED
			sprite_2d.flip_h = direction < 0
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		# Handle animations
		if not is_on_floor():
			if velocity.y < 0:
				sprite_2d.play("jumping")
			else:
				sprite_2d.play("falling")
		elif direction != 0:
			sprite_2d.play("running")
		else:
			sprite_2d.play("default")

	move_and_slide()

# This gets called when the attack animation finishes
func _on_Sprite2D_animation_finished():
	if sprite_2d.animation == "attacking":
		is_attacking = false
		if not is_on_floor():
			if velocity.y < 0:
				sprite_2d.play("jumping")
			else:
				sprite_2d.play("falling")
		elif Input.get_axis("left", "right") != 0:
			sprite_2d.play("running")
		else:
			sprite_2d.play("default")
