extends CharacterBody2D

@onready var sprite = $Smoothing2D/sprite
@onready var atk_area = $atk_area

var speed = 450.0
var jump_velocity = -900.0
var accel = 25
var decel = 40
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jumped = false
var released_jump = false
var j_buffered = false
var attacking = false
var cam_offset: float = 400.0


func _ready():
	remove_child(atk_area)

func attack():
	attacking = true
	add_child(atk_area)
	sprite.play("attack")
	await sprite.animation_finished
	attacking = false
	remove_child(atk_area)
	
	
func _physics_process(delta):
	# gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	
	#jump spaghetti don't look at this please i'm begging you
	if Input.is_action_just_pressed("jump") or j_buffered and Input.is_action_pressed("jump"):
		if is_on_floor():
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
	if velocity.y >= 0:
		jumped = false

	if Input.is_action_just_pressed("attack") and not attacking:
		attack()

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


func change_offset(offset: float):
	await get_tree().create_timer(.2).timeout
	cam_offset = lerp(cam_offset, offset, 0.025)
	

func get_hit():
	get_tree().reload_current_scene()
