extends Area2D


func _ready():
	await body_entered
	Dialogic.start("first_choice")
