extends Control

var GamePaused = false
var PreTimeScale = 1
func enter(node):
	var tween = get_tree().create_tween()

	tween.tween_property(node, "scale", Vector2.ONE*1.2, 0.2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.play()
func exit(node):
	var tween = get_tree().create_tween()

	tween.tween_property(node, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.play()
func Open():
	GlobalScript.GamePaused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	GamePaused = true
	PreTimeScale = Engine.time_scale
	Engine.time_scale = 0
	self.visible = true
func Close():
	GlobalScript.GamePaused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	GamePaused = false
	Engine.time_scale = PreTimeScale
	self.visible = false
func _input(event):
	if event.is_action_pressed("Escape") and not GlobalScript.PlayerDead: #Quit game
		
		if GamePaused == false: #Show menu
			Open()
		else: #Hide menu
			Close()

func quit():
	get_tree().quit()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) #Hides mouse
	$QuitButton.pressed.connect(quit)
	$QuitButton.mouse_entered.connect(enter.bind($QuitButton))
	$QuitButton.mouse_exited.connect(exit.bind($QuitButton))
func _process(delta: float) -> void:
	if GlobalScript.PlayerDead == true and GamePaused == true:
		GamePaused = false
		self.visible = false
