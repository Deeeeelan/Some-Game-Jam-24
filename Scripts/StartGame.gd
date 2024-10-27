extends Button

func ButtonPressed():
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")


func _ready():
	self.pressed.connect(ButtonPressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
