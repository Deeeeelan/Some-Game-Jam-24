extends Node




func tick():
	var enemyScene = preload("res://Assets/Enemies/enemy.tscn")
	var enemy = enemyScene.instantiate()
	enemy.Player = $Node3D/Player
	add_child(enemy)
	enemy.owner = $Node3D/Enemies
	print(enemy)
func _ready() -> void:
	$EnemyTick.timeout.connect(tick)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
