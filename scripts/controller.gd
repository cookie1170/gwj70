extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -900.0

@onready var sprite = $sprite

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jumped = false
var released_jump = false
var j_buffered = false


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") or j_buffered:
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			jumped = true
			sprite.play("jump")
		if not is_on_floor() and not j_buffered:
			j_buffered = true
			await get_tree().create_timer(.15).timeout
			j_buffered = false
	if not is_on_floor() and not jumped:
		sprite.play("fall")
	if not Input.is_action_pressed("ui_accept") and jumped:
		velocity.y -= velocity.y/2
		jumped = false
		gravity *= 2.5
	if is_on_floor():
		gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		if is_on_floor() and not jumped :
			sprite.play("run")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor() and not jumped:
			sprite.play("idle")

	move_and_slide()
