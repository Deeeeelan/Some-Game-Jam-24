extends CharacterBody3D

@onready var head = $Head
@onready var root = get_tree().current_scene

@export var max_health = 100
@export var health = 100
@export var lerp_speed = 10
@export var mouse_sens = 0.25
@export var InvertControls = false
@export var speed = 5.0
@export var jump_velocity = 4.5
@export var damage = 50
@export var sword_cooldown = 1

var direction = Vector3.ZERO
var SwordCD = false

func death():
	# Handle death animation etc.
	print(self, " has died")
	root.Death()

func take_damage(damage):
	health -= damage
	if health <= 0:
		death()

func _input(event):
	if not GlobalScript.PlayerDead:
		if event is InputEventMouseMotion and GlobalScript.GamePaused == false:
			rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
			head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
			head.rotation.x = clamp(head.rotation.x,deg_to_rad(-89),deg_to_rad(89))
		if event.is_action_pressed("Attack") and not SwordCD:
			SwordCD = true
			var DetectedItems = $Head/Area3D.get_overlapping_bodies()
			$Head/SwordSlash.play()
			if $AnimationPlayer.is_playing():
				$AnimationPlayer.stop()
			$AnimationPlayer.play("Sword_Slash")
			for i in DetectedItems:
				if i is CharacterBody3D and i.has_meta("Enemy") and i.get_meta("Enemy") == true: 
					i.take_damage(damage)
			await get_tree().create_timer(sword_cooldown).timeout
			SwordCD = false
		
		

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and not GlobalScript.PlayerDead:
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Vector2.ZERO
	if not GlobalScript.PlayerDead:
		input_dir = Input.get_vector("Left", "Right", "Forward", "Backward")
	if InvertControls:
		input_dir *= -1
	direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta*lerp_speed)
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
