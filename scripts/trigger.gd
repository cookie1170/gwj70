extends Area2D

@export var dialogue: String


func _ready():
	await body_entered
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	Dialogic.start(dialogue)
	tween.tween_property($"../Path2D/PathFollow2D", "progress", $"../Path2D/PathFollow2D".progress + 1150, .75)
