extends Node

var levelingDecounce = false

func LevelRequirement() -> int:
	return GlobalScript.CurrentLevel ** 2 + 25

func LevelUp():
	if levelingDecounce == false:
		levelingDecounce = true
		GlobalScript.CurrentEXP -= LevelRequirement()
		GlobalScript.CurrentLevel += 1
		levelingDecounce = false

func tick():
	var enemyScene = preload("res://Assets/Enemies/enemy.tscn")
	var enemy = enemyScene.instantiate()
	enemy.Player = $Node3D/Player
	add_child(enemy)
	enemy.owner = $Node3D/Enemies
	
func _ready() -> void:
	$EnemyTick.timeout.connect(tick)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if GlobalScript.CurrentEXP >= LevelRequirement():
		LevelUp()
