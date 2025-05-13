extends CharacterBody2D

const SPEED = 100.0
const GRAVITY = 1200.0
const ATTACK_RANGE = 30.0
const DETECTION_RANGE = 200.0

@onready var sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var collision_area: CollisionShape2D = $CollisionArea
@onready var attack_cooldown_timer: Timer = $AttackCooldownTimer

var target = null
var health := 3

var is_attacking: bool = false
var is_hurt: bool = false
var is_dead: bool = false
var facing_left: bool = false
var death_animation_finished: bool = false

var attack_on_cooldown: bool = false
var movement_locked: bool = false
var can_attack: bool = true

func _ready():
	attack_area.body_entered.connect(func(body):
		print("!!! ANYTHING entered attack area:", body.name)
	)

	add_to_group("enemies")
	
	attack_cooldown_timer.one_shot = true
	attack_cooldown_timer.wait_time = 1
	attack_cooldown_timer.timeout.connect(_on_AttackCooldownTimer_timeout)

func _physics_process(delta: float) -> void:
	if is_dead:
		return  # <- If dead, do NOTHING anymore

	if is_hurt:
		move_and_slide()
		return

	if not is_on_floor():
		velocity.y += GRAVITY * delta

	if not target or not is_instance_valid(target):
		var players = get_tree().get_nodes_in_group("players")
		if players.size() > 0:
			target = players[0]
			
	if not target or not is_instance_valid(target) or target.is_dead:
		idle()
		return
	
	if target and is_instance_valid(target):
		var distance = global_position.distance_to(target.global_position)

		if movement_locked:
			velocity = Vector2.ZERO
		else:
			if distance <= ATTACK_RANGE and can_attack and not is_attacking and not target.is_dead:
				attack()
			elif distance <= DETECTION_RANGE:
				move_towards_player()
			else:
				idle()
	else:
		idle()

	move_and_slide()

func move_towards_player():
	if not target or not is_instance_valid(target):
		return

	var direction = (target.global_position - global_position)
	var distance = direction.length()

	# Prevent jitter when too close
	if distance < 2.0:
		direction = Vector2.ZERO
	else:
		direction = direction.normalized()

	# Only update x velocity if not frozen
	velocity.x = direction.x * SPEED

	# Flip only if we're moving significantly left or right
	if abs(direction.x) > 0.1:
		var now_facing_left = direction.x < 0
		if now_facing_left != facing_left:
			facing_left = now_facing_left
			sprite_2d.flip_h = facing_left

	# Handle animations
	if distance > ATTACK_RANGE:
		if not is_attacking and not is_hurt and sprite_2d.animation != "walk":
			sprite_2d.play("walk")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if not is_attacking and not is_hurt and sprite_2d.animation != "default":
			sprite_2d.play("default")

func attack():
	if not can_attack or is_attacking or is_hurt or attack_on_cooldown:
		return

	can_attack = false
	is_attacking = true
	attack_area.monitoring = true
	attack_area.force_update_transform() # Optional but useful
	attack_area.monitoring = true
	movement_locked = true
	velocity.x = 0
	sprite_2d.play("attack")

	await sprite_2d.animation_finished
	_on_attack_finished()

func _on_attack_finished():
	is_attacking = false
	attack_area.monitoring = false
	movement_locked = false
	attack_on_cooldown = true
	attack_cooldown_timer.start()

	if target and is_instance_valid(target):
		var d = global_position.distance_to(target.global_position)
		sprite_2d.play("walk" if d <= DETECTION_RANGE else "default")
	else:
		sprite_2d.play("default")

func idle():
	velocity.x = move_toward(velocity.x, 0, SPEED)
	if not is_attacking and not is_hurt and sprite_2d.animation != "default":
		sprite_2d.play("default")

func take_damage(amount: int):
	if is_dead:
		return

	health -= amount
	if health > 0:
		is_hurt = true
		is_attacking = false
		attack_area.monitoring = false
		movement_locked = false
		can_attack = true
		attack_on_cooldown = false
		velocity.x = 0
		sprite_2d.play("hurt")

		await sprite_2d.animation_finished
		_on_hurt_finished()
	else:
		die()

func _on_hurt_finished():
	is_hurt = false
	movement_locked = false

	if target and is_instance_valid(target):
		var d = global_position.distance_to(target.global_position)
		if d <= ATTACK_RANGE and not is_attacking and can_attack:
			attack()
		elif d <= DETECTION_RANGE:
			sprite_2d.play("walk")
		else:
			sprite_2d.play("default")
	else:
		sprite_2d.play("default")

func die():
	is_dead = true
	is_attacking = false
	is_hurt = false
	attack_area.monitoring = false
	movement_locked = true

	collision_area.disabled = true
	$AttackArea/AttackArea.disabled = true

	set_collision_layer(0)
	set_collision_mask(0)

	velocity = Vector2.ZERO
	sprite_2d.play("death")

	await sprite_2d.animation_finished
	death_animation_finished = true

func _on_AttackCooldownTimer_timeout() -> void:
	attack_on_cooldown = false
	can_attack = true
	
func _on_AttackArea_body_entered(body):
	if is_attacking and body.is_in_group("players") and body.has_method("take_damage") and not body.is_dead:
		body.take_damage(1)
