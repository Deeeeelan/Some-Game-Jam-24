extends Node

var levelingDecounce = false
@onready var EnemyNode = $Node3D/Enemies
@onready var player = $Node3D/Player

func ModifierMessage(Title, Description):
	$Control/Modifer/Title.text = str(Title) 
	$Control/Modifer/Description.text = str(Description)

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
	var PixelSize = $Control/Pixelation.material.get_shader_parameter("pixelSize")
	if PixelSize < 16:
		$Control/Pixelation.material.set_shader_parameter("pixelSize", PixelSize + 1)
func Saturated():
	if $Node3D/WorldEnvironment.environment.adjustment_saturation < 20:
		$Node3D/WorldEnvironment.environment.adjustment_saturation += 2
		
var BassBoosts = 0
func BassBoost(): # This is where the funny starts (Had to nerf, was too good, sorry)
	if BassBoosts < 1:
		BassBoosts + 1
		var effect = AudioServer.get_bus_effect(0,0)
		effect.volume_db += 1
		var effect2 = AudioServer.get_bus_effect(0,1)
		effect2.gain += 1.5
		var effect3 = AudioServer.get_bus_effect(0,2)
		effect3.drive += 0.28

func Slippery():
	if player.lerp_speed > 2:
		player.lerp_speed = ceil(player.lerp_speed/2)
func Speedy():
	if player.speed < 30:
		player.speed += 2.5

func InvertControls():
	player.InvertControls = not player.InvertControls

func SubwaySurfing():
	$Control/Modifiers/SubwaySurfers.visible = true
	$Control/Modifiers/SubwaySurfers.play()


const FORCED_MODIFIER = ""

var ModifierRates = {
	"BassBoost" = {
		Title = "Loud",
		Description = "Loud is funny",
		Func = Callable(self, "BassBoost"),
		Weight = 32,
	},
	"SubwaySurfing" = {
		Title = "Subway Surfing",
		Description = "Keeping your attention span",
		Func = Callable(self, "SubwaySurfing"),
		Weight = 24,
	},
	"InvertControls" = {
		Title = "Inverted Controls",
		Description = "huh?!",
		Func = Callable(self, "InvertControls"),
		Weight = 16,
	},
	"Flipped" = {
		Title = "Flipped",
		Description = "Upside down",
		Func = Callable(self, "Flipped"),
		Weight = 16,
	},
	"SpeedUp" = {
		Title = "Speed Up",
		Description = "Going fast!",
		Func = Callable(self, "SpeedUp"),
		Weight = 8,
	},
	"Askew" = {
		Title = "Askew",
		Description = "A bit to the side",
		Func = Callable(self, "Askew"),
		Weight = 8,
	},
	"Speedy" = {
		Title = "Speedy",
		Description = "Going fast! (just for you, though)",
		Func = Callable(self, "Speedy"),
		Weight = 8,
	},
	"Slippery" = {
		Title = "Slippery",
		Description = "Ice all over the ground",
		Func = Callable(self, "Slippery"),
		Weight = 8,
	},
	"Saturated" = {
		Title = "Saturated",
		Description = "yeah... not much else",
		Func = Callable(self, "Saturated"),
		Weight = 8,
	},
	"Pixelation" = {
		Title = "Pixelation",
		Description = "Retro...",
		Func = Callable(self, "Pixelation"),
		Weight = 8,
	},
	"LoseFPS" = {
		Title = "Lowered FPS",
		Description = "Its gettin choppy",
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
	return snapped(GlobalScript.CurrentLevel * 5 + 10, 10) 
# snapped() returns the closest value to the second arguement (Round to the xth number)

func LevelUp():
	if levelingDecounce == false:
		levelingDecounce = true
		GlobalScript.CurrentEXP -= LevelRequirement()
		GlobalScript.CurrentLevel += 1
		player.max_health += 5
		player.damage += 5
		if player.sword_cooldown > 0.05:
			player.sword_cooldown -= 0.05
		# Level Up
		ChooseRandomModifier()
		levelingDecounce = false

func tick():
	var enemyScene = preload("res://Assets/Enemies/enemy.tscn")
	var enemy = enemyScene.instantiate()
	
	enemy.Player = player
	EnemyNode.add_child(enemy)
	var randomSpawn = $Node3D/Spawns.get_children().pick_random()
	enemy.position = randomSpawn.position

func RegenTick():
	if player.health < player.max_health:
		player.health += floor(player.max_health/100)
func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("DebugMenu"):
		ModifierMessage("Super Secret Debug Mode Enabled", "")
		GlobalScript.DebugMode = true
	if Input.is_action_pressed("DebugAction1") and GlobalScript.DebugMode:
		GlobalScript.CurrentEXP += 1
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
