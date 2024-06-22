extends CharacterBody2D

#literally just copy pasted this from a yt tutorial
@onready var nav_agent: NavigationAgent2D = $nav_agent
@onready var sprite = $sprite
@onready var atk_area = $atk_area
@onready var atk_hitbox = $atk_area/atk_hitbox
@onready var target = get_tree().get_first_node_in_group("player")
@onready var hearts = [$heart_1, $heart_2, $heart_3]
@onready var i_frame_timer = $i_frame_timer


var speed = 300
var acceleration = 7
var attacking = false
var health = 3
var i_frames = false
var nav_enabled = false


func _ready():
	remove_child(atk_area)
	$"../Path2D/PathFollow2D/Camera2D".offset.x = clampf(0, 0, 500)


func attack():
	attacking = true
	await get_tree().create_timer(.4).timeout
	add_child(atk_area)
	await sprite.animation_finished
	if is_instance_valid(atk_area):
		remove_child(atk_area)
	await get_tree().create_timer(.8).timeout
	attacking = false


func _physics_process(delta):
	var dist = global_transform.origin.distance_to(target.global_position)
	var direction = Vector2.ZERO
	
	if dist <= 1000 and gm.can_move:
		nav_enabled = true
	else:
		nav_enabled = false
	
	if dist >= 100 and nav_enabled:
		direction = nav_agent.get_next_path_position() - global_position
		direction = direction.normalized()
	
	velocity = velocity.lerp(direction * speed, acceleration * delta)
	
	if velocity.x and not attacking:
		sprite.play("run")
	if velocity.x < 0:
		atk_area.position.x = -40
		sprite.flip_h = true
	if velocity.x > 0:
		atk_area.position.x = 40
		sprite.flip_h = false
	
	if dist <= 200 and not attacking:
		attack()
	
	move_and_slide()

func _on_timer_timeout():
	if nav_enabled:
		nav_agent.target_position = target.global_position
	
func get_hit():
	if not i_frames:
		i_frames = true
		i_frame_timer.start()
		health -= 1
		if health == 0:
			queue_free()
		var heart = hearts.front()
		if is_instance_valid(heart):
			heart.play("heart_hit")
		hearts.remove_at(0)


func get_hit_two():
	if not i_frames:
		i_frames = true
		i_frame_timer.start()
		health -= 2
		if health <= 0:
			queue_free()
		var heart_1 = hearts.front()
		if is_instance_valid(heart_1):
			heart_1.play("heart_hit")
		hearts.remove_at(0)
		var heart_2 = hearts.front()
		if is_instance_valid(heart_2):
			heart_2.play("heart_hit")
		hearts.remove_at(0)


func _on_atk_entered(body):
	body.get_hit()
	remove_child(atk_area)


func _on_i_frame_timeout():
	i_frames = false