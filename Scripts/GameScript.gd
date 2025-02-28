extends Node

var levelingDecounce = false
@onready var EnemyNode = $Node3D/Enemies
@onready var player = $Node3D/Player
@export var Loading = false
@export var MobDMGMulti = 1.0
@export var MobSpeedMulti = 1.0
@export var MobHealthMulti = 1.0

var gamePath = "res://Scenes/Game.tscn"
var loading_status
var progress : Array

func enter(node):
	var tween = get_tree().create_tween()

	tween.tween_property(node, "scale", Vector2.ONE*1.2, 0.2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.play()
func exit(node):
	var tween = get_tree().create_tween()

	tween.tween_property(node, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.play()
	
func ModifierMessage(Title, Description):
	var TitleText = $Control/Modifer/Title
	var DescText = $Control/Modifer/Description
	$Control/Modifer/Title.text = str(Title) 
	$Control/Modifer/Description.text = str(Description)
	var tween = get_tree().create_tween()
	TitleText.position = Vector2(-100,-100)
	tween.tween_property(TitleText,"position", Vector2.ZERO, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	var tween2 = get_tree().create_tween()
	DescText.position = Vector2(-100,-100)
	tween2.tween_property(DescText,"position", Vector2(0,62), 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).set_delay(0.5)

func EnemyDied(Pos : Vector3):
	player.health = clamp(player.health+25,0,player.max_health)
	var PartiScene = load("res://Assets/Misc/deathparticle.tscn")
	var Particle = PartiScene.instantiate()
	$Node3D/Particles.add_child(Particle)
	Particle.position = Pos
	Particle.get_node("CPUParticles3D").emitting = true
	await Particle.get_node("CPUParticles3D").finished
	Particle.queue_free()
	
func DMGMulti():
	MobDMGMulti += 0.1
func HealthMulti():
	MobHealthMulti += 0.15
func SpeedMulti():
	MobSpeedMulti += 0.15
func LoseFPS(): # Hopefully this will not cause any problems in the future...
	if Engine.max_fps > 120 or Engine.max_fps == 0:
		Engine.max_fps = 120
	Engine.max_fps = clampi(roundi(Engine.max_fps*0.85), 16, 60)

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
		Engine.time_scale += 0.2

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
		BassBoosts += 1
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
		player.speed += 3.5

func InvertControls():
	player.InvertControls = not player.InvertControls

func SubwaySurfing():
	$Control/Modifiers/SubwaySurfers.visible = true
	$Control/Modifiers/SubwaySurfers.play()


const FORCED_MODIFIER = ""

var ModifierRates = {
	"HealthMulti" = {
		Title = "Healthier Enemies",
		Description = "tanky - ish",
		Func = Callable(self, "HealthMulti"),
		Weight = 16,
	},
	"SpeedMulti" = {
		Title = "Faster Enemies",
		Description = "cardio",
		Func = Callable(self, "SpeedMulti"),
		Weight = 16,
	},
	"DMGMulti" = {
		Title = "Stronger Enemies",
		Description = "Strong and Scary",
		Func = Callable(self, "DMGMulti"),
		Weight = 16,
	},
	"BassBoost" = {
		Title = "Loud",
		Description = "Loud is funny",
		Func = Callable(self, "BassBoost"),
		Weight = 46,
	},
	"SubwaySurfing" = {
		Title = "Subway Surfing",
		Description = "Keeping your attention span",
		Func = Callable(self, "SubwaySurfing"),
		Weight = 48,
	},
	"InvertControls" = {
		Title = "Inverted Controls",
		Description = "huh?!",
		Func = Callable(self, "InvertControls"),
		Weight = 32,
	},
	"Flipped" = {
		Title = "Flipped",
		Description = "Upside down",
		Func = Callable(self, "Flipped"),
		Weight = 32,
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
	if $BGMusic.playing:
		var tween = get_tree().create_tween()
		tween.tween_property($BGMusic, "volume_db", -80, 1.0).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT)
		tween.play()
		tween.finished.connect(func():
			$BGMusic.stop()
			)
	GlobalScript.PlayerDead = true
	# Engine.time_scale = 0.2
	$Control/DeathScreen.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func LevelRequirement() -> int:
	return snapped(GlobalScript.CurrentLevel * 10 + 10, 10) 
# snapped() returns the closest value to the second arguement (Round to the xth number)

func LevelUp():
	if levelingDecounce == false:
		levelingDecounce = true
		GlobalScript.CurrentEXP -= LevelRequirement()
		GlobalScript.CurrentLevel += 1
		GlobalScript.TotalScore += 25
		# You know what, screw this, no clamping the wait time , it will now approach zero
		# Risky, but I don't really care as I have been debugging this for too long (I'm just dumb)
		# $EnemyTick.wait_time = ((0.875) ** float(GlobalScript.CurrentLevel)) * 8.0  # scrap this it doesn't work
		$EnemyTick.wait_time = clampf($EnemyTick.wait_time - (GlobalScript.CurrentLevel*0.15),0.5,10)
		player.max_health += 5
		player.damage += 5
		if player.sword_cooldown > 0.05:
			player.sword_cooldown -= 0.05
		if GlobalScript.CurrentLevel >= 15 and not $BGMusic.playing:
			$BGMusic.volume_db = -80
			$BGMusic.play()
			var tween = get_tree().create_tween()
			tween.tween_property($BGMusic, "volume_db", 0, 6.0).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT)
		
		# Level Up
		ChooseRandomModifier()
		levelingDecounce = false

var FORCED_ENEMY = ""
var EnemyRates = {
	"Sussy Guy" : {
		"FilePath" : "res://Assets/Enemies/Sussy Guy.tscn",
		"Weight" : 10000,
		"minLvl" : 0,
		"maxLvl" : INF,
	},
	"Robot Guy" : {
		"FilePath" : "res://Assets/Enemies/Robot Guy.tscn",
		"Weight" : 85,
		"minLvl" : 25,
		"maxLvl" : INF,
	},
	"Purple Guy" : {
		"FilePath" : "res://Assets/Enemies/Purple Guy.tscn",
		"Weight" : 85,
		"minLvl" : 20,
		"maxLvl" : INF,
	},
	"Speedy Guy" : {
		"FilePath" : "res://Assets/Enemies/Speedy Guy.tscn",
		"Weight" : 15,
		"minLvl" : 15,
		"maxLvl" : INF,
	},
	"Very Super Angry Guy" : {
		"FilePath" : "res://Assets/Enemies/Very Super Angry Guy.tscn",
		"Weight" : 55,
		"minLvl" : 65,
		"maxLvl" : INF,
	},
	"Super Angry Guy" : {
		"FilePath" : "res://Assets/Enemies/Super Angry Guy.tscn",
		"Weight" : 35,
		"minLvl" : 35,
		"maxLvl" : 100,
	},
	"Very Angry Guy" : {
		"FilePath" : "res://Assets/Enemies/Very Angry Guy.tscn",
		"Weight" : 5,
		"minLvl" : 15,
		"maxLvl" : 65,
	},
	"Angry Guy" : {
		"FilePath" : "res://Assets/Enemies/Angry Guy.tscn",
		"Weight" : 1,
		"minLvl" : 0,
		"maxLvl" : 40,
	},
}
func LoadEnemy(Path):
	var enemyScene = load(Path)
	var enemy = enemyScene.instantiate()
	
	EnemyNode.add_child(enemy)
	enemy.Player = player
	enemy.health *= MobHealthMulti
	enemy.max_health *= MobHealthMulti
	enemy.Damage *= MobDMGMulti
	enemy.SPEED *= MobSpeedMulti
	var randomSpawn = $Node3D/Spawns.get_children().pick_random()
	enemy.position = randomSpawn.position
func tick():
	# Select random enemy
	if FORCED_ENEMY != "":
		pass
	for EnemyName in EnemyRates:
		var Enemy = EnemyRates[EnemyName]
		if Enemy.minLvl <= GlobalScript.CurrentLevel and GlobalScript.CurrentLevel <= Enemy.maxLvl:
			if randi_range(1,Enemy.Weight) == 1:
				LoadEnemy(Enemy.FilePath)
				
				break


func RegenTick():
	if player.health < player.max_health and player.StillTicks < 5:
		player.health += floor(player.max_health/100)
func Retry():
	if not Loading:
		Loading = true
		ResourceLoader.load_threaded_request(gamePath)
		$Control/FG.scale = Vector2.ZERO
		$Control/FG.visible = true
		var tween = get_tree().create_tween()
		tween.tween_property($Control/FG, "scale", Vector2.ONE, 2.0).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT)
		tween.play()
		
func _input(_event: InputEvent) -> void:
	if Input.is_action_pressed("DebugMenu"):
		ModifierMessage("Super Secret Debug Mode Enabled", "")
		GlobalScript.DebugMode = true
	if Input.is_action_pressed("DebugAction1") and GlobalScript.DebugMode:
		GlobalScript.CurrentEXP += 100
	if Input.is_action_pressed("DebugAction2") and GlobalScript.DebugMode:
		player.max_health = 99999999
		player.health = 99999999
func _ready() -> void:
	Engine.max_fps = 0
	Engine.time_scale = 1
	GlobalScript.TotalScore = 0
	GlobalScript.CurrentEXP = 0
	GlobalScript.CurrentLevel = 0
	GlobalScript.PlayerDead = false
	GlobalScript.GamePaused = false
	$EnemyTick.wait_time = 6
	$EnemyTick.timeout.connect(tick)
	$RegenTick.timeout.connect(RegenTick)
	$Control/FG.scale = Vector2.ONE
	$Control/FG.visible = true
	
	$Control/DeathScreen/RetryButton.pressed.connect(Retry)
	$Control/DeathScreen/RetryButton.mouse_entered.connect(enter.bind($Control/DeathScreen/RetryButton))
	$Control/DeathScreen/RetryButton.mouse_exited.connect(exit.bind($Control/DeathScreen/RetryButton))
	
	var tween = get_tree().create_tween()

	tween.tween_property($Control/FG, "scale", Vector2.ZERO, 2.0).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT)
	tween.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if GlobalScript.CurrentEXP >= LevelRequirement():
		LevelUp()
	# Update the status:
	loading_status = ResourceLoader.load_threaded_get_status(gamePath, progress)
	
	# Check the loading status:
	match loading_status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			pass # progress[0] * 100
		ResourceLoader.THREAD_LOAD_LOADED:
			get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(gamePath))
