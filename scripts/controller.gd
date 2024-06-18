extends CharacterBody2D


@onready var sprite = $smoothing_sprite/sprite
@onready var atk_area = $atk_area
@onready var atk_hitbox = $atk_area/atk_hitbox
@onready var coyote_timer = $coyote_timer
@onready var hearts = [$smoothing_hearts/heart_1, $smoothing_hearts/heart_2, $smoothing_hearts/heart_3]
@onready var shoot_cd = $shoot_cd
@onready var i_frame_timer = $i_frame_timer


var speed: float = 450.0
var jump_velocity: float = -900.0
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
var i_frames: bool = false


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
	
	
func shoot():
	var arrow = arrow.instantiate()
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
		if coyote_timer.is_stopped():
			coyote_timer.start()
	
	#jump spaghetti don't look at this please i'm begging you
	if Input.is_action_just_pressed("jump") or j_buffered and Input.is_action_pressed("jump"):
		
		if jump_available:
			velocity.y = jump_velocity
			jumped = true
			if not attacking and not on_cd:
				sprite.play("jump")
		
		if not is_on_floor() and not j_buffered:
			j_buffered = true
			await get_tree().create_timer(.2).timeout
			j_buffered = false

	if not Input.is_action_pressed("jump") and jumped:
		velocity.y -= velocity.y/2
		jumped = false
		gravity *= 2.5
	
	if is_on_floor():
		gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
		jump_available = true
		coyote_timer.stop()
	
	if velocity.y >= 0:
		jumped = false

	if Input.is_action_just_pressed("attack") and not attacking and gm.chosen_weapon == 1:
		attack()
	
	if Input.is_action_just_pressed("attack") and not on_cd and not attacking and gm.chosen_weapon == 2:
		shoot()

	var direction = Input.get_axis("left", "right")
	
	if direction:
		velocity.x = move_toward(velocity.x, direction * speed, accel)
		if direction == -1:
			sprite.flip_h = true
			atk_area.position.x = -60
			change_offset(-400)
		if direction == 1:
			sprite.flip_h = false
			atk_area.position.x = 60
			change_offset(400)
		if is_on_floor() and not attacking and not on_cd:
			sprite.play("run")
	
	if !direction:
		velocity.x = move_toward(velocity.x, 0, decel)
		if not attacking and not jumped and not on_cd:
			sprite.play("idle")
	
	if not is_on_floor() and not jumped and not attacking and not on_cd:
		sprite.play("fall")
	
	#$"../PhantomCamera2D".set_follow_offset(Vector2(cam_offset, 0))
	
	move_and_slide()


func _on_atk_entered(body):
	body.get_hit()
	remove_child(atk_area)


func change_offset(offset: float):
	await get_tree().create_timer(.2).timeout
	cam_offset = lerp(cam_offset, offset, 0.025)
	

func get_hit():
	if not i_frames:
		i_frame_timer.start()
		health -= 1
		if health == 0:
			get_tree().reload_current_scene()
		var heart = hearts.front()
		if is_instance_valid(heart):
			heart.play("heart_hit")
		hearts.remove_at(0)
	
	
func on_coyote_timeout():
	jump_available = false


func _on_i_frame_timeout():
	i_frames = false
