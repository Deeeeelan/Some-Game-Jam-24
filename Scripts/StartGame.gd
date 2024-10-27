extends Button



func ButtonPressed():
	print("Loading Scene!?!?")
	
	
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")
	

		


func _ready():
	self.pressed.connect(ButtonPressed)
	
# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
#	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
