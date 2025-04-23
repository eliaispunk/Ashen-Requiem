extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@onready var sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var is_attacking: bool = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# Handle attack input
	if Input.is_action_just_pressed("attack") and is_on_floor() and not is_attacking:
		is_attacking = true
		sprite_2d.play("attacking")
		return  # Skip movement while attacking

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
		# Flip sprite depending on direction
		sprite_2d.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	# Select animations based on state
	if not is_attacking:
		if not is_on_floor():
			sprite_2d.play("jumping")
		elif direction != 0:
			sprite_2d.play("running")
		else:
			sprite_2d.play("default")

	move_and_slide()
	
func _on_Sprite2D_animation_finished():
	if sprite_2d.animation == "attacking":
		is_attacking = false
		if not is_on_floor():
			sprite_2d.play("jumping")
		elif Input.get_axis("left", "right") != 0:
			sprite_2d.play("running")
		else:
			sprite_2d.play("default")
