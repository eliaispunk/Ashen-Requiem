extends CharacterBody2D

const SPEED        = 300.0
const JUMP_VELOCITY = -550.0
const GRAVITY      = 1200.0

@onready var sprite_2d: AnimatedSprite2D     = $AnimatedSprite2D
@onready var collision_area: CollisionShape2D = $CollisionArea

# ─── NEW STATE ───────────────────────────────────────────────────────────
var health: int        = 5
var is_hurt: bool      = false
var is_dead: bool      = false

# ─── EXISTING STATE ─────────────────────────────────────────────────
var is_attacking: bool = false
var facing_left := false

func _ready():
	add_to_group("players")
	sprite_2d.animation_finished.connect(_on_Sprite2D_animation_finished)

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# When hurt, ignore player input until hurt animation finishes
	if is_hurt:
		move_and_slide()
		return

	# ── gravity, movement & attack code as before ──
	if not is_on_floor():
		if velocity.y > 0:
			velocity.y += GRAVITY * 1.3 * delta
		else:
			velocity.y += GRAVITY * delta

	if Input.is_action_just_pressed("attack") and is_on_floor() and not is_attacking:
		is_attacking = true
		$AttackArea.monitoring = true
		sprite_2d.play("attacking")
		velocity.x = 0
		return

	if not is_attacking:
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		var direction := Input.get_axis("left", "right")
		if direction != 0:
			velocity.x = direction * SPEED
			var now_facing_left = direction < 0
			if now_facing_left != facing_left:
				facing_left = now_facing_left
				sprite_2d.flip_h = facing_left
				$CollisionArea.position.x =  3.0 if facing_left else -4.333
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		if not is_on_floor():
			sprite_2d.play("jumping" if velocity.y < 0 else "falling")
		elif direction != 0:
			sprite_2d.play("running")
		else:
			sprite_2d.play("default")

	move_and_slide()

# ─── NEW: Damage API ───────────────────────────────────────────────────────
func take_damage(amount: int) -> void:
	if is_dead or is_hurt:
		return

	health -= amount
	if health > 0:
		is_hurt = true
		is_attacking = false
		$AttackArea.monitoring = false
		sprite_2d.play("hurt")
		_on_hurt_recover()
	else:
		die()

func _on_hurt_recover() -> void:
	is_hurt = false
	is_attacking = false
	$AttackArea.monitoring = false
	# back to default or running animation
	if not is_on_floor():
		sprite_2d.play("jumping" if velocity.y < 0 else "falling")
	elif Input.get_axis("left", "right") != 0:
		sprite_2d.play("running")
	else:
		sprite_2d.play("default")

signal died

func die() -> void:
	if is_dead:
		return
	is_dead = true
	is_hurt = false
	is_attacking = false
	velocity = Vector2.ZERO
	$AttackArea.monitoring = false
	collision_area.disabled = true
	sprite_2d.play("death")
	await sprite_2d.animation_finished
	sprite_2d.stop()  # Freeze on last frame
	print("EMITTING DEATH SIGNAL")
	emit_signal("died")

# ─── EXISTING ANIMATION-FINISHED HANDLER ──────────────────────────────────
func _on_Sprite2D_animation_finished():
	if sprite_2d.animation == "death":
		return  # Never override death frame

	# Only reset attack state if finishing "attacking"
	if sprite_2d.animation == "attacking":
		is_attacking = false
		$AttackArea.monitoring = false

	# Don't override animation if still hurt
	if is_hurt:
		return

# ─── YOUR EXISTING ENEMY-COLLISION HOOK ──────────────────────────────────
func _on_AttackArea_body_entered(body):
	if is_attacking and body.is_in_group("enemies") and body.has_method("take_damage"):
		body.take_damage(1)
