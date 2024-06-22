extends AnimatedSprite2D

var moving_left = false
var moving_right = false


func _ready():
	Dialogic.signal_event.connect(_dialogic_signal)


func _physics_process(delta):
	if moving_left:
		position.x -= 300 * delta
		flip_h = true
	if moving_right:
		position.x += 300 * delta
		flip_h = false
	if position.x <= 4000:
		moving_left = false
		await get_tree().create_timer(.5).timeout
		
		moving_right = true
	if position.x >= 4700 and moving_right:
		queue_free()


func _dialogic_signal(argument):
	if argument == "sasquatch":
		moving_left = true
		show()
		play("default")
