extends AnimatedSprite2D

var moving = false


func _ready():
	Dialogic.signal_event.connect(_dialogic_signal)


func _physics_process(delta):
	position = $"../Path2D2/PathFollow2D".position
	print($"../Path2D2/PathFollow2D".progress_ratio)
	if moving:
		var tween = get_tree().create_tween()
		tween.tween_property($"../Path2D2/PathFollow2D", "progress_ratio", 1.1, 4.5)
		await get_tree().create_timer(1.8).timeout
		flip_h = false
		await get_tree().create_timer(3.5).timeout
		queue_free()


func _dialogic_signal(argument):
	if argument == "faerie":
		show()
		play("default")
		moving = true
