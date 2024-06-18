extends RigidBody2D

@onready var hitbox_area = $hitbox_area

# Called when the node enters the scene tree for the first time.
func _ready():
	apply_central_impulse(Vector2(cos(rotation), sin(rotation)) * 2000)
	remove_child(hitbox_area)
	await get_tree().create_timer(.05).timeout
	add_child(hitbox_area)


func _on_body_entered(body):
	body.get_hit()
