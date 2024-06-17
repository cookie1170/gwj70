extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	apply_central_impulse(Vector2(cos(rotation), sin(rotation)) * 2000)
	


func _on_body_entered(body):
	body.get_hit()
