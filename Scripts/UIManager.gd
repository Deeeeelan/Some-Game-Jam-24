extends Control
@export var Player: CharacterBody3D

@onready var root = get_tree().current_scene
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	$Score/Label.text = "Score: " + str(GlobalScript.TotalScore)
	$Health/Label.text = str(clamp(Player.health,0,INF)) + "/" + str(Player.max_health)
	$EXP/Label.text = str(GlobalScript.CurrentEXP) + " / " + str(root.LevelRequirement())
	$Level/Label.text = "Level: " + str(GlobalScript.CurrentLevel)
	
