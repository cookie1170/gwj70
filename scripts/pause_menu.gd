extends Control

@onready var pause = $pause


var paused: bool = false


func _ready():
	GuiTransitions.hide("pause_c")
	GuiTransitions.hide("settings_c")

func _process(_delta):
	if Input.is_action_just_pressed("pause") and not GuiTransitions.in_transition():
		pausef()


func pausef():
	if paused:
		get_tree().paused = false
		GuiTransitions.hide("pause_c")
		GuiTransitions.hide("settings_c")
	else:
		get_tree().paused = true
		GuiTransitions.show("pause_c")
	paused = !paused


func _on_resume_pressed():
	pausef()


func _on_quit_pressed():
	get_tree().quit()


func _on_restart_pressed():
	pausef()
	$"../player".fail()


func _on_settings_pressed():
	GuiTransitions.hide("pause_c")
	GuiTransitions.show("settings_c")
