extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -550.0
const GRAVITY = 1200.0

@onready var sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_area: CollisionShape2D = $CollisionArea

var is_attacking: bool = false
var facing_left := false

func _ready():
	add_to_group("players") # <-- ✨ Important!

func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		if velocity.y > 0:
			velocity.y += GRAVITY * 1.3 * delta
		else:
			velocity.y += GRAVITY * delta

	# Handle attack input
	if Input.is_action_just_pressed("attack") and is_on_floor() and not is_attacking:
		is_attacking = true
		$AttackArea.monitoring = true
		sprite_2d.play("attacking")
		velocity.x = 0
		return

	else:
		# Handle movement and input normally if not attacking
		if not is_attacking:
			if Input.is_action_just_pressed("jump") and is_on_floor():
				velocity.y = JUMP_VELOCITY

			var direction := Input.get_axis("left", "right")
			if direction:
				velocity.x = direction * SPEED

				# Check if we need to flip
				var now_facing_left = direction < 0
				if now_facing_left != facing_left:
					facing_left = now_facing_left
					sprite_2d.flip_h = facing_left
					$AttackArea.position.x = -43.0 if facing_left else 0.0
					$CollisionArea.position.x = 3.0 if facing_left else -4.333

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
