extends Button

var gamePath = "res://Scenes/Game.tscn"
var loading_status
var progress : Array

func ButtonPressed():
	ResourceLoader.load_threaded_request(gamePath)
	
func enter():
	var tween = get_tree().create_tween()

	tween.tween_property(self, "scale", Vector2.ONE*1.2, 0.2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.play()
func exit():
	var tween = get_tree().create_tween()

	tween.tween_property(self, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.play()

func _ready():
	
	self.pressed.connect(ButtonPressed)
	self.mouse_entered.connect(enter)
	self.mouse_exited.connect(exit)

func _process(_delta: float):
	# Update the status:
	loading_status = ResourceLoader.load_threaded_get_status(gamePath, progress)
	
	# Check the loading status:
	match loading_status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			pass # progress[0] * 100
		ResourceLoader.THREAD_LOAD_LOADED:
			get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(gamePath))
