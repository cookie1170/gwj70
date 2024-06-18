extends CharacterBody2D

#literally just copy pasted this from a yt tutorial
@onready var nav_agent: NavigationAgent2D = $nav_agent
@onready var sprite = $sprite
@onready var target = get_tree().get_first_node_in_group("player")
@onready var hearts = [$heart_1, $heart_2, $heart_3]
@onready var shoot_point = $shoot_point_point/shoot_point
@onready var shoot_point_point = $shoot_point_point


var speed = 300
var acceleration = 7
var attacking = false
var health = 3
var arrow = preload("res://scenes/reusable/arrow.tscn")


func attack():
	attacking = true
	var arrow = arrow.instantiate()
	arrow.rotation = get_angle_to(target.global_position)
	arrow.position = shoot_point.position
	add_child(arrow)
	await get_tree().create_timer(1.2).timeout
	attacking = false


func _physics_process(delta):
	var dist = global_transform.origin.distance_to(target.global_position)
	var direction = Vector2.ZERO
	
	if dist >= 500:
		direction = nav_agent.get_next_path_position() - global_position
		direction = direction.normalized()
	else:
		direction = -(nav_agent.get_next_path_position() - global_position)
		direction = direction.normalized()
	velocity = velocity.lerp(direction * speed, acceleration * delta)
	
	if velocity.x and not attacking:
		sprite.play("run")
	if velocity.x < 0:
		sprite.flip_h = true
	if velocity.x > 0:
		sprite.flip_h = false
	if not velocity.x and not attacking:
		sprite.play("idle")
	
	if dist <= 500 and not attacking:
		attack()

	move_and_slide()


func _on_timer_timeout():
	nav_agent.target_position = target.global_position


func get_hit():
	health -= 1
	if health == 0:
		queue_free()
	var heart = hearts.front()
	if is_instance_valid(heart):
		heart.play("heart_hit")
	hearts.remove_at(0)
