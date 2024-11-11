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
	var tween = get_tree().create_tween()
	var camera = $Node3D/Player/Head/Camera3D
	tween.tween_property(camera, "quaternion", camera.quaternion * Quaternion.from_euler(Vector3(0, 0, deg_to_rad(randi_range(-9,9)))), 0.65).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)


func Flipped():
	var tween = get_tree().create_tween()
	var camera = $Node3D/Player/Head/Camera3D
	tween.tween_property(camera, "quaternion", camera.quaternion * Quaternion.from_euler(Vector3(0, 0, deg_to_rad(180))), 1.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

func SpeedUp():
	if Engine.time_scale <= 2:
		Engine.time_scale += 0.1

func Pixelation():
	print($Control/Pixelation.material)
	var PixelSize = $Control/Pixelation.material.get_shader_parameter("pixelSize")
	if PixelSize < 16:
		$Control/Pixelation.material.set_shader_parameter("pixelSize", PixelSize + 1)
		
func Slippery():
	if player.lerp_speed > 2:
		player.lerp_speed = ceil(player.lerp_speed/2)
func Speedy():
	if player.speed < 30:
		player.speed += 2.5

const FORCED_MODIFIER = "Speedy"

var ModifierRates = {
	"Speedy" = {
		Title = "Speedy",
		Description = "Speedy",
		Func = Callable(self, "Speedy"),
		Weight = 2,
	},
	"Slippery" = {
		Title = "Slippery",
		Description = "Slippery",
		Func = Callable(self, "Slippery"),
		Weight = 2,
	},
	"Pixelation" = {
		Title = "Pixelation",
		Description = "Pixelation",
		Func = Callable(self, "Pixelation"),
		Weight = 2,
	},
	"SpeedUp" = {
		Title = "SpeedUp",
		Description = "SpeedUp",
		Func = Callable(self, "SpeedUp"),
		Weight = 2,
	},
	"Flipped" = {
		Title = "Flipped",
		Description = "Flipped",
		Func = Callable(self, "Flipped"),
		Weight = 2,
	},
	"Askew" = {
		Title = "Askew",
		Description = "Askew",
		Func = Callable(self, "Askew"),
		Weight = 2,
	},
	"LoseFPS" = {
		Title = "Uhoh its getting choppy",
		Description = "how unfortunate",
		Func = Callable(self, "LoseFPS"),
		Weight = 1,
	},
}

func ChooseRandomModifier():
	if FORCED_MODIFIER != "":
		var Modifier = ModifierRates[FORCED_MODIFIER]
		Modifier.Func.call()
		ModifierMessage(Modifier.Title, Modifier.Description)
		return
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
	enemy.position = Vector3(0,5,0)

func RegenTick():
	if player.health < player.max_health:
		player.health += 1

func _ready() -> void:
	GlobalScript.TotalScore = 0
	GlobalScript.CurrentEXP = 0
	GlobalScript.CurrentLevel = 0
	$EnemyTick.timeout.connect(tick)
	$RegenTick.timeout.connect(RegenTick)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if GlobalScript.CurrentEXP >= LevelRequirement():
		LevelUp()
