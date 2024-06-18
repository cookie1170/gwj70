extends Area2D

var layout = Dialogic.start("woods")	

func _ready():
	#layout.register_character(load("res://dialogic/narrator.dch"), $"../player")
	await body_entered
	Dialogic.start("woods")
