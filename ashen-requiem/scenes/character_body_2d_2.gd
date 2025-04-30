extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -550.0
const GRAVITY = 1200.0
const KNOCKBACK_DURATION := 0.2
const KNOCKBACK_FORCE := 200

@onready var sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var is_attacking: bool = false
var knockback_velocity := Vector2.ZERO
var knockback_timer := 0.0

func _ready():
	add_to_group("players") # <-- ✨ Important!

func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		if velocity.y > 0:
			velocity.y += GRAVITY * 1.3 * delta
		else:
			velocity.y += GRAVITY * delta

	# Check for knockback collisions
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider and collider.is_in_group("enemies") and knockback_timer <= 0:
			apply_knockback(collider.global_position)

	# Handle attack input
	if Input.is_action_just_pressed("attack") and is_on_floor() and not is_attacking:
		is_attacking = true
		$AttackArea.monitoring = true
		sprite_2d.play("attacking")
		velocity.x = 0
		return

	# Handle knockback movement
	if knockback_timer > 0:
		knockback_timer -= delta
		velocity.x = knockback_velocity.x
	else:
		# Handle movement and input normally if not attacking
		if not is_attacking:
			if Input.is_action_just_pressed("jump") and is_on_floor():
				velocity.y = JUMP_VELOCITY

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

# Attack animation finished
func _on_Sprite2D_animation_finished():
	if sprite_2d.animation == "attacking":
		is_attacking = false
		$AttackArea.monitoring = false
		# Reevaluate animation
		if not is_on_floor():
			if velocity.y < 0:
				sprite_2d.play("jumping")
			else:
				sprite_2d.play("falling")
		elif Input.get_axis("left", "right") != 0:
			sprite_2d.play("running")
		else:
			sprite_2d.play("default")

# Player attack hitbox hit an enemy
func _on_AttackArea_body_entered(body):
	if is_attacking and body.is_in_group("enemies") and body.has_method("take_damage"):
		body.take_damage(1)

# Apply knockback away from the enemy
func apply_knockback(enemy_position: Vector2):
	var direction := (global_position - enemy_position).normalized()
	knockback_velocity = direction * KNOCKBACK_FORCE
	knockback_timer = KNOCKBACK_DURATION

func _on_ContactArea_body_entered(body):
	if body.is_in_group("enemies") and knockback_timer <= 0:
		apply_knockback(body.global_position)
