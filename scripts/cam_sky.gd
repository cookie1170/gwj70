extends Camera2D


func _process(_delta):
	position = $"../Path2D/PathFollow2D".position
