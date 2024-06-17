extends CharacterBody2D

@onready var sprite = $Smoothing2D/sprite
@onready var atk_area = $atk_area
@onready var atk_hitbox = $atk_area/atk_hitbox
@onready var coyote_timer = $coyote_timer
@onready var hearts = [$heart_1, $heart_2, $heart_3]
@onready var shoot_cd = $shoot_cd

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

func _ready():
	remove_child(atk_area)


func attack():
	attacking = true
	add_child(atk_area)
	sprite.play("attack")
	await sprite.animation_finished
	attacking = false
	if is_instance_valid(atk_area):
		remove_child(atk_area)
	
	
func shoot():
	var arrow = arrow.instantiate()
	arrow.rotation = get_angle_to(get_global_mouse_position())
	add_child(arrow)
	print("bruh")
	on_cd = true
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
			if not attacking:
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

	if Input.is_action_just_pressed("attack") and not attacking:
		attack()
	
	if Input.is_action_just_pressed("rmb") and not on_cd:
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
		if is_on_floor() and not attacking:
			sprite.play("run")
	if !direction:
		velocity.x = move_toward(velocity.x, 0, decel)
		if not attacking and not jumped:
			sprite.play("idle")
	
	if not is_on_floor() and not jumped and not attacking:
		sprite.play("fall")
	
	$"../PhantomCamera2D".set_follow_offset(Vector2(cam_offset, 0))
	move_and_slide()


func _on_atk_entered(body):
	body.get_hit()
	remove_child(atk_hitbox)


func change_offset(offset: float):
	await get_tree().create_timer(.2).timeout
	cam_offset = lerp(cam_offset, offset, 0.025)
	

func get_hit():
	health -= 1
	if health == 0:
		get_tree().reload_current_scene()
	var heart = hearts.front()
	if is_instance_valid(heart):
		heart.play("heart_hit")
	hearts.remove_at(0)
	
	
func on_coyote_timeout():
	jump_available = false
