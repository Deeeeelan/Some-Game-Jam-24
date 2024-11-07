extends Node

var levelingDecounce = false
@onready var EnemyNode = $Node3D/Enemies
@onready var player = $Node3D/Player

func ModifierMessage(Title, Description):
	print("ModifierMessage", str(Title), str(Description))

func TestModifier():
	print("Modifier active")
func TestModifier2():
	print("Modifier active")



var ModifierRates = {
	"Test" = {
		Name = "1",
		Description = "a",
		Func = Callable(self, "TestModifier"),
		Weight = 2,
	},
	"Test2" = {
		Name = "2",
		Description = "b",
		Func = Callable(self, "TestModifier2"),
		Weight = 1,
	},
}

func ChooseRandomModifier():
	for ModifierName in ModifierRates:
		var Modifier = ModifierRates[ModifierName]
		if randi_range(1,Modifier.Weight) == 1:
			Modifier.Func.call()
			ModifierMessage(Modifier.Name, Modifier.Description)
			break

func Death():
	GlobalScript.PlayerDead = true
	Engine.time_scale = 0.2
	$Control/DeathScreen.visible = true
	
func LevelRequirement() -> int:
	return snapped(GlobalScript.CurrentLevel ** 2 + 25, 10) 
# snapped() returns the closest value to the second arguement (Round to the xth number)

func LevelUp():
	if levelingDecounce == false:
		levelingDecounce = true
		GlobalScript.CurrentEXP -= LevelRequirement()
		GlobalScript.CurrentLevel += 1
		# Level Up
		ChooseRandomModifier()
		levelingDecounce = false

func tick():
	var enemyScene = preload("res://Assets/Enemies/enemy.tscn")
	var enemy = enemyScene.instantiate()
	
	enemy.Player = player
	EnemyNode.add_child(enemy)
	
	
func _ready() -> void:
	GlobalScript.TotalScore = 0
	GlobalScript.CurrentEXP = 0
	GlobalScript.CurrentLevel = 0
	$EnemyTick.timeout.connect(tick)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if GlobalScript.CurrentEXP >= LevelRequirement():
		LevelUp()
