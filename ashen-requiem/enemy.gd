extends CharacterBody2D

const SPEED = 100.0
const GRAVITY = 1200.0
const DETECTION_RANGE = 200.0
const ATTACK_AREA_RIGHT = 35.5
const ATTACK_AREA_LEFT = -35.0

@onready var sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_collider: CollisionShape2D = $AttackArea/AttackShape
@onready var main_collider: CollisionShape2D = $CollisionArea
@onready var attack_cooldown_timer: Timer = $AttackCooldownTimer
@onready var attack_sfx: AudioStreamPlayer2D = $AttackSFX

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
	add_to_group("enemies")
	attack_area.monitoring = true  # Always on
	attack_cooldown_timer.one_shot = true
	attack_cooldown_timer.wait_time = 1
	attack_cooldown_timer.timeout.connect(_on_AttackCooldownTimer_timeout)

func _physics_process(delta: float) -> void:
	if is_dead:
		return

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
		move_and_slide()
		return

	face_player()

	if movement_locked:
		velocity = Vector2.ZERO
	else:
		if _is_player_in_attack_area() and can_attack and not is_attacking and not target.is_dead:
			attack()
		elif global_position.distance_to(target.global_position) <= DETECTION_RANGE:
			move_towards_player()
		else:
			idle()

	move_and_slide()

func face_player():
	if not target or not is_instance_valid(target):
		return
	var dir_to_player = target.global_position.x - global_position.x
	var now_facing_left = dir_to_player < 0
	if now_facing_left != facing_left:
		facing_left = now_facing_left
		sprite_2d.flip_h = facing_left
		attack_area.position.x = ATTACK_AREA_LEFT if facing_left else ATTACK_AREA_RIGHT

func move_towards_player():
	if not target or not is_instance_valid(target):
		return

	face_player()

	# if player in attack area but attack on cooldown → stop & idle
	if _is_player_in_attack_area() and (not can_attack or is_attacking):
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if not is_attacking and not is_hurt:
			sprite_2d.play("default")
		return

	var direction = (target.global_position - global_position)
	var distance = direction.length()

	if distance < 2.0:
		direction = Vector2.ZERO
	else:
		direction = direction.normalized()

	velocity.x = direction.x * SPEED

	if not is_attacking and not is_hurt:
		sprite_2d.play("walk")

func _is_player_in_attack_area() -> bool:
	for body in attack_area.get_overlapping_bodies():
		if body.is_in_group("players") and not body.is_dead:
			return true
	return false

func attack():
	if not can_attack or is_attacking or is_hurt or attack_on_cooldown:
		return

	can_attack = false
	is_attacking = true
	movement_locked = true
	velocity.x = 0
	sprite_2d.play("attack")
	attack_sfx.play()

	await sprite_2d.animation_finished
	_on_attack_finished()

func _on_attack_finished():
	if is_dead:
		return

	is_attacking = false
	movement_locked = false
	attack_on_cooldown = true
	attack_cooldown_timer.start()

	if target and is_instance_valid(target):
		if global_position.distance_to(target.global_position) <= DETECTION_RANGE:
			sprite_2d.play("walk")
		else:
			sprite_2d.play("default")
	else:
		sprite_2d.play("default")

func idle():
	velocity.x = move_toward(velocity.x, 0, SPEED)
	if not is_attacking and not is_hurt:
		sprite_2d.play("default")

func take_damage(amount: int):
	if is_dead:
		return

	health -= amount
	if health > 0:
		is_hurt = true
		is_attacking = false
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
	if is_dead:
		return

	is_hurt = false
	movement_locked = false

	if target and is_instance_valid(target):
		if _is_player_in_attack_area() and not is_attacking and can_attack:
			attack()
		elif global_position.distance_to(target.global_position) <= DETECTION_RANGE:
			sprite_2d.play("walk")
		else:
			sprite_2d.play("default")
	else:
		sprite_2d.play("default")

func die():
	is_dead = true
	is_attacking = false
	is_hurt = false
	movement_locked = true

	set_collision_layer(0)
	set_collision_mask(0)

	velocity = Vector2.ZERO
	sprite_2d.play("death")

	await sprite_2d.animation_finished
	death_animation_finished = true

func _on_AttackCooldownTimer_timeout() -> void:
	attack_on_cooldown = false
	can_attack = true

func _apply_attack_damage():
	for body in attack_area.get_overlapping_bodies():
		if body.is_in_group("players") and body.has_method("take_damage") and not body.is_dead:
			body.take_damage(1)

func _on_animated_sprite_2d_frame_changed() -> void:
	if sprite_2d.animation == "attack" and sprite_2d.frame == 3:
		_apply_attack_damage()
