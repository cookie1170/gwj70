extends CharacterBody2D

@export var move_cam_y: bool = true


@onready var sprite = $sprite
@onready var atk_area = $atk_area
@onready var atk_hitbox = $atk_area/atk_hitbox
@onready var coyote_timer = $coyote_timer
@onready var hearts = [$heart_1, $heart_2, $heart_3]
@onready var shoot_cd = $shoot_cd
@onready var i_frame_timer = $i_frame_timer


var speed: float = 650.0
var jump_velocity: float = -750.0
var accel: float = 25
var decel: float = 40
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var jumped: bool = false
var released_jump: bool = false
var j_buffered: bool = false
var attacking: bool = false
var cam_offset: float = 400.0
var jump_available: bool = true
var health: int = clampi(3, 0, 3)
var on_cd: bool = false
var arrow = preload("res://scenes/reusable/arrow.tscn")
var axe = preload("res://scenes/reusable/axe.tscn")
var i_frames: bool = false
var was_in_air: bool = false


func _ready():
	remove_child(atk_area)

func attack():
	attacking = true
	add_child(atk_area)
	sprite.play("attack_sword")
	await sprite.animation_finished
	attacking = false
	if is_instance_valid(atk_area):
		remove_child(atk_area)


func attack_axe():
	var axe = axe.instantiate()
	attacking = true
	axe.impulse = 1000
	if rad_to_deg(get_angle_to(get_global_mouse_position())) <= -90 or rad_to_deg(get_angle_to(get_global_mouse_position())) >= 90:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	on_cd = true
	sprite.play("attack_axe")
	i_frames = true
	i_frame_timer.start(0.05)
	await sprite.animation_finished
	attacking = false
	axe.rotation = get_angle_to(get_global_mouse_position())
	axe.position = position
	get_tree().current_scene.add_child(axe)
	shoot_cd.start(2)
	await shoot_cd.timeout
	on_cd = false
	

func shoot():
	var arrow = arrow.instantiate()
	attacking = true
	arrow.impulse = 2000
	if rad_to_deg(get_angle_to(get_global_mouse_position())) <= -90 or rad_to_deg(get_angle_to(get_global_mouse_position())) >= 90:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	on_cd = true
	sprite.play("attack_bow")
	i_frames = true
	i_frame_timer.start(0.05)
	await sprite.animation_finished
	attacking = false
	arrow.rotation = get_angle_to(get_global_mouse_position())
	arrow.position = position
	get_tree().current_scene.add_child(arrow)
	shoot_cd.start()
	await shoot_cd.timeout
	on_cd = false

func _physics_process(delta):
	# gravity
	if not is_on_floor():
		velocity.y += gravity * delta
		was_in_air = true
		if coyote_timer.is_stopped():
			coyote_timer.start()
	
	#jump spaghetti don't look at this please i'm begging you
	if Input.is_action_just_pressed("jump") and gm.can_move or j_buffered and Input.is_action_pressed("jump") and gm.can_move:
		if jump_available:
			velocity.y = jump_velocity
			jumped = true
			if not attacking:
				sprite.play("jump")
		
		if not is_on_floor() and not j_buffered:
			j_buffered = true
			await get_tree().create_timer(.3).timeout
			j_buffered = false

	if not Input.is_action_pressed("jump") and jumped:
		if velocity.y < 0:
			velocity.y -= velocity.y/2
		jumped = false
		gravity *= 2.5
		
	if is_on_floor():
		gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
		if not jump_available:
			jumped = false
		jump_available = true
		coyote_timer.stop()
		if was_in_air:
			if gm.chosen_location == "none" or "meadow":
				$land_grass.pitch_scale = randf_range(0.9, 1.1)
				$land_grass.play()
			if gm.chosen_location == "cave":
				$land_stone.pitch_scale = randf_range(0.9, 1.1)
				$land_stone.play()
			if gm.chosen_location == "beans":
				$land_cloud.pitch_scale = randf_range(0.9, 1.1)
				$land_cloud.play()
			was_in_air = false
			if gm.chosen_location != "beans":
				$"../Path2D/PathFollow2D/Camera2D".shake(0.2, 1, 0.2)
			else:
				$"../Camera2D".shake(0.2, 1, 0.2)

	if Input.is_action_just_pressed("attack") and not attacking and gm.chosen_weapon == "sword":
		attack()
	
	if Input.is_action_just_pressed("attack") and not on_cd and not attacking and gm.chosen_weapon == "axe":
		attack_axe()
	
	if Input.is_action_just_pressed("attack") and not on_cd and not attacking and gm.chosen_weapon == "bow":
		shoot()

	var direction = Input.get_axis("left", "right")
	
	if direction and gm.can_move:
		velocity.x = move_toward(velocity.x, direction * speed, accel)
		if direction == -1:
			sprite.flip_h = true
			atk_area.position.x = -60
		if direction == 1:
			sprite.flip_h = false
			atk_area.position.x = 60
		if is_on_floor() and not attacking:
			sprite.play("run")
	
	if !direction:
		velocity.x = move_toward(velocity.x, 0, decel)
		if not attacking and not jumped:
			sprite.play("idle")
	
	if not is_on_floor() and not jumped and not attacking:
		sprite.play("fall")
	
	if not gm.can_move:
		velocity.x = 0
		sprite.play("idle")
	
	
	if move_cam_y:
		$"../Path2D/PathFollow2D/Camera2D".offset.y = position.y / 3
	
	move_and_slide()


func _on_atk_entered(body):
	body.get_hit()
	remove_child(atk_area)


func get_hit():
	if not i_frames:
		i_frame_timer.start()
		health -= 1
		if health <= 0:
			fail()
		for heart in hearts:
			if heart.get_index() - 4 > health - 1:
				heart.play("heart_hit")
			else:
				heart.play("heart_full")


func get_hit_two():
	if not i_frames:
		i_frame_timer.start()
		health -= 2
		if health <= 0:
			fail()
		var heart_1 = hearts.front()
		if is_instance_valid(heart_1):
			heart_1.play("heart_hit")
		hearts.remove_at(0)
		var heart_2 = hearts.front()
		if is_instance_valid(heart_2):
			heart_2.play("heart_hit")
		hearts.remove_at(0)


func on_coyote_timeout():
	jump_available = false


func _on_i_frame_timeout():
	i_frames = false


func fail():
	sprite.hide()
	$heart_1.hide()
	$heart_2.hide()
	$heart_3.hide()
	health = 3
	if not move_cam_y:
		transition.fail(self, Vector2(575, $"../Camera2D".position.y + 64) )
	elif move_cam_y:
		transition.fail(self, $"../Path2D/PathFollow2D/Camera2D/boundary_cam".global_position)
	await get_tree().create_timer(.7).timeout
	$heart_1.play("heart_full")
	$heart_2.play("heart_full")
	$heart_3.play("heart_full")
	sprite.show()
	$heart_1.show()
	$heart_2.show()
	$heart_3.show()
	i_frames = false
