extends Node

var chosen_weapon: int = 0
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
		get_tree().change_scene_to_file("res://scenes/levels/meadow.tscn")
