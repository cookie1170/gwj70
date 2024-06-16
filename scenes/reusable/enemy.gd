extends CharacterBody2D

#literally just copy pasted this from a yt tutorial

var speed = 300
var acceleration = 7
var attacking = false

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var sprite = $sprite
@onready var atk_area = $atk_area
@onready var target = get_tree().get_first_node_in_group("player")

func _ready():
	remove_child(atk_area)

func attack():
	attacking = true
	sprite.play("attack")
	await get_tree().create_timer(.4).timeout
	add_child(atk_area)
	await sprite.animation_finished
	attacking = false
	remove_child(atk_area)

func _physics_process(delta):
	var direction = Vector2.ZERO
	
	direction = navigation_agent.get_next_path_position() - global_position
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
	if not velocity.x and not attacking:
		sprite.play("idle")
	var dist = global_transform.origin.distance_to(target.global_position)
	
	if dist <= 200 and not attacking:
		attack()
	
	move_and_slide()

func _on_timer_timeout():
	navigation_agent.target_position = target.global_position
	
func get_hit():
	queue_free()
	Dialogic.start("timeline")

func _on_atk_entered(body):
	body.get_hit()
