extends Control

var GamePaused = false
var PreTimeScale = 1

func _input(event):
	if event.is_action_pressed("Escape"): #Quit game
		
		if GamePaused == false: #Show menu
			GlobalScript.GamePaused = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			GamePaused = true
			PreTimeScale = Engine.time_scale
			Engine.time_scale = 0
			self.visible = true
		else: #Hide menu
			GlobalScript.GamePaused = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			GamePaused = false
			Engine.time_scale = PreTimeScale
			self.visible = false

func quit():
	get_tree().quit()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) #Hides mouse
	$QuitButton.pressed.connect(quit)
