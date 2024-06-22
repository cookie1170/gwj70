extends Node

var chosen_weapon: String = "none"
var creature: String = "none"
var can_move: bool = true


func _ready():
	Dialogic.signal_event.connect(_dialogic_signal)
	

func _dialogic_signal(argument):
	if argument == "giant" or argument == "sasquatch" or argument == "faerie":
		creature = argument
	if argument == "off":
		can_move = false
	if argument == "on":
		can_move = true
	if argument == "meadow":
		transition.change_scene("res://scenes/levels/meadow.tscn")
	if argument == "cave":
		transition.change_scene("res://scenes/levels/cave.tscn")
	if argument == "sword" or argument == "axe" or argument == "bow":
		chosen_weapon = argument
