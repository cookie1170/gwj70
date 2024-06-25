extends Node

var chosen_weapon: String = "none"
var can_move: bool = true
var chosen_location: String = "none"


func _ready():
	Dialogic.signal_event.connect(_dialogic_signal)
	

func _dialogic_signal(argument):
	if argument == "off":
		can_move = false
	if argument == "on":
		can_move = true
	if argument == "meadow":
		transition.change_scene("res://scenes/levels/meadow.tscn")
		chosen_location = "meadow"
	if argument == "cave":
		transition.change_scene("res://scenes/levels/cave.tscn")
		chosen_location = "cave"
	if argument == "beans":
		transition.change_scene("res://scenes/levels/sky.tscn")
		chosen_location = "beans"
	if argument == "sword" or argument == "axe" or argument == "bow":
		chosen_weapon = argument
	if argument == "restart":
		transition.change_scene("res://scenes/levels/woods.tscn")
		chosen_weapon = "none"
		chosen_location = "none"
		can_move = true
	if argument == "quit":
		get_tree().quit()
