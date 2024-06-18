extends RigidBody2D

@onready var hitbox_area = $hitbox_area


@export var impulse = 2000


func _ready():
	apply_central_impulse(Vector2(cos(rotation), sin(rotation)) * impulse)
	remove_child(hitbox_area)
	await get_tree().create_timer(.05).timeout
	add_child(hitbox_area)


func _on_body_entered(body):
	body.get_hit()
