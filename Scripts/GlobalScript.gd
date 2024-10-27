# This script is used in every scene.

extends Node
var FullScreen = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	pass # Replace with function body.
	
func _input(event):
	
	if event.is_action_pressed("Escape"): #Quit game
		get_tree().quit()
		
	if event.is_action_pressed("toggle_fullscreen"):#Toggle fullscreen
		if FullScreen == true:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			FullScreen = false
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			FullScreen = true
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
