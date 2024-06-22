extends AnimatedSprite2D

var moving_left = false
var moving_right = false


func _ready():
	Dialogic.signal_event.connect(_dialogic_signal)


func _dialogic_signal(argument):
	if argument == "giant":
		moving_left = true
		show()
		play("walk")


func _on_frame_changed():
	if moving_left:
		$"../Path2D/PathFollow2D/Camera2D".shake(0.05, 5, 5)
		position.x = lerpf(position.x, position.x - 50, 3)
		if position.x <= 4000:
			moving_left = false
			moving_right = true
	if moving_right:
		$"../Path2D/PathFollow2D/Camera2D".shake(0.05, 5, 5)
		position.x = lerpf(position.x, position.x + 50, 3)
		flip_h = true
		if position.x >= 4900:
			queue_free()
