extends Node

var levelingDecounce = false
@onready var EnemyNode = $Node3D/Enemies
@onready var player = $Node3D/Player

func ModifierMessage(Title, Description):
	print("ModifierMessage", str(Title), str(Description))
	$Control/Modifer/Label.text = str(Title) + "\n" + str(Description)

func LoseFPS(): # Hopefully this will not cause any problems in the future...
	if Engine.max_fps > 120 or Engine.max_fps == 0:
		Engine.max_fps = 120
	Engine.max_fps = clampi(roundi(Engine.max_fps*0.9), 16, 60)

func Askew():
	$Node3D/Player/Head/Camera3D.rotate_z(deg_to_rad(randi_range(-15,15))) # Can stack, have fun

func SpeedUp():
	if Engine.time_scale <= 2:
		Engine.time_scale += 0.1

var ModifierRates = {
	"SpeedUp" = {
		Title = "SpeedUp",
		Description = "SpeedUp",
		Func = Callable(self, "SpeedUp"),
		Weight = 1,
	},
	"Askew" = {
		Title = "Askew",
		Description = "Askew",
		Func = Callable(self, "Askew"),
		Weight = 2,
	},
	"LoseFPS" = {
		Title = "Uhoh its getting choppy",
		Description = "No more FPS, how unfortunate",
		Func = Callable(self, "LoseFPS"),
		Weight = 1,
	},
}

func ChooseRandomModifier():
	for ModifierName in ModifierRates:
		var Modifier = ModifierRates[ModifierName]
		if randi_range(1,Modifier.Weight) == 1:
			Modifier.Func.call()
			ModifierMessage(Modifier.Title, Modifier.Description)
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
