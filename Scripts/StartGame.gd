extends Button

func ButtonPressed():
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")


func _ready():
	self.pressed.connect(ButtonPressed)
