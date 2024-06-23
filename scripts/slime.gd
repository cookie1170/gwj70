extends CharacterBody2D

#a huge mess now
@onready var sprite = $sprite
@onready var atk_area = $atk_area
@onready var atk_hitbox = $atk_area/atk_hitbox
@onready var target = get_tree().get_first_node_in_group("player")
@onready var hearts = [$heart_1, $heart_2, $heart_3]
@onready var i_frame_timer = $i_frame_timer


var speed = 200
var attacking = false
var health = 3
var i_frames = false
var nav_enabled = false
var direction = 0.0
var dist = 0.0


func _physics_process(delta):
	dist = global_transform.origin.distance_to(target.global_position)
	
	
	if dist <= 700 and gm.can_move:
		nav_enabled = true
	else:
		nav_enabled = false
	
	if not nav_enabled:
		sprite.play("idle")


	velocity.x = direction * speed
	
	if direction:
		sprite.play("run")
	if direction == 1:
		sprite.flip_h = true
	if direction == -1:
		sprite.flip_h = false

	move_and_slide()


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
			Dialogic.start_timeline("win")
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


func _on_i_frame_timeout():
	i_frames = false


func get_direction():
	if global_position > target.global_position and nav_enabled and dist >= 100:
		return -1.0
	elif global_position < target.global_position and nav_enabled and dist >= 100:
		return 1.0
	elif global_position == target.global_position:
		return 0.0
	else:
		return 0.0


func _on_update_timer_timeout():
	direction = get_direction()
