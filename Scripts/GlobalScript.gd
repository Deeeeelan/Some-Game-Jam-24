# This script is used in every scene.

extends Node

@export var GamePaused = false
@export var TotalScore = 0
@export var CurrentEXP = 0
@export var CurrentLevel = 0
@export var HighScore = 0

var FullScreen = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func _input(event):
	if event.is_action_pressed("toggle_fullscreen"):#Toggle fullscreen
		if FullScreen == true:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			FullScreen = false
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			FullScreen = true
