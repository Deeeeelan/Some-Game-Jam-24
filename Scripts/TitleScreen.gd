extends Node

@onready var texture_rect = $Control/Checkerboard


var gamePath = "res://Scenes/Game.tscn"
var loading_status
var progress : Array

func ButtonPressed():
	ResourceLoader.load_threaded_request(gamePath)
	$Control/FG.scale = Vector2.ZERO
	$Control/FG.visible = true
	var tween = get_tree().create_tween()

	tween.tween_property($Control/FG, "scale", Vector2.ONE, 2.0).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT)
	tween.play()
func enter():
	var tween = get_tree().create_tween()

	tween.tween_property($Control/StartButton, "scale", Vector2.ONE*1.2, 0.2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.play()
func exit():
	var tween = get_tree().create_tween()

	tween.tween_property($Control/StartButton, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
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
		


func _ready():
	# Initial tween
	TweenSize()
	
	$Control/StartButton.pressed.connect(ButtonPressed)
	$Control/StartButton.mouse_entered.connect(enter)
	$Control/StartButton.mouse_exited.connect(exit)

func _process(_delta: float):
	# Update the status:
	loading_status = ResourceLoader.load_threaded_get_status(gamePath, progress)
	
	# Check the loading status:
	match loading_status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			pass # progress[0] * 100
		ResourceLoader.THREAD_LOAD_LOADED:
			get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(gamePath))
