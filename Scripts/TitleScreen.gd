extends Node

@onready var texture_rect = $Control/Checkerboard

@export var Loading = false

var gamePath = "res://Scenes/Game.tscn"
var loading_status
var progress : Array
var TransitionCompleted = false
func ButtonPressed():
	if not Loading:
		Loading = true
		ResourceLoader.load_threaded_request(gamePath)
		$Control/FG.scale = Vector2.ZERO
		$Control/FG.visible = true
		var tween = get_tree().create_tween()
		tween.tween_property($Control/FG, "scale", Vector2.ONE, 2.0).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT)
		tween.play()
		tween.finished.connect(func():
			TransitionCompleted = true
			)
func QuitGame():
	get_tree().quit()
func enter(node):
	var tween = get_tree().create_tween()

	tween.tween_property(node, "scale", Vector2.ONE*1.2, 0.2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.play()
func exit(node):
	var tween = get_tree().create_tween()

	tween.tween_property(node, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.play()



func TweenSize():
	var r = 1
	texture_rect.pivot_offset = Vector2(texture_rect.size/2)
	while true:
		var current_scale = Vector2.ONE*1.2
		var target_scale = current_scale * 2
		var tween = get_tree().create_tween()
	
		tween.tween_property(texture_rect, "scale", target_scale, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.play()
		await tween.finished
		
		var tween1andahalf = get_tree().create_tween()
		# NOTE: rotation in control nodes are in radians NOT degress like in the inspector 
		# (wished I knew this a while ago)
		tween1andahalf.tween_property(texture_rect, "rotation", deg_to_rad(r*180), 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween1andahalf.play()
		r = -r
		await tween1andahalf.finished
		
		var tween2 = get_tree().create_tween()
		tween2.tween_property(texture_rect, "scale", current_scale, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween2.play()
		await tween2.finished
		
		#tween2.stop()
		
func TitleGlitch():
	if randi_range(1,3) == 1:
		$Control/Logo.pivot_offset = $Control/Logo.size / 2
		$Control/Logo.position = Vector2($Control/Logo.position.x,0) + Vector2(randi_range(-8,8), randi_range(-8,8))
		$Control/Logo.scale = Vector2.ONE * randf_range(0.975, 1.025)

func _ready():
	# Initial tween
	TweenSize()
	
	$Control/StartButton.pressed.connect(ButtonPressed)
	$Control/QuitButton.pressed.connect(QuitGame)
	$Control/StartButton.mouse_entered.connect(enter.bind($Control/StartButton))
	$Control/StartButton.mouse_exited.connect(exit.bind($Control/StartButton))
	$Control/QuitButton.mouse_entered.connect(enter.bind($Control/QuitButton))
	$Control/QuitButton.mouse_exited.connect(exit.bind($Control/QuitButton))
	$GlitchTick.timeout.connect(TitleGlitch)
func _process(_delta: float):
	# Update the status:
	loading_status = ResourceLoader.load_threaded_get_status(gamePath, progress)
	
	# Check the loading status:

	if loading_status == ResourceLoader.THREAD_LOAD_LOADED and TransitionCompleted:
		get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(gamePath))
