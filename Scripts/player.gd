extends CharacterBody3D

@onready var head = $Head

@export var max_health = 100
@export var health = 100

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

const mouse_sens = 0.25

var lerp_speed = 10

var direction = Vector3.ZERO

func death():
	# Handle death animation etc.
	print(self, " has died")

func take_damage(damage):
	health -= damage
	if health <= 0:
		death()

func _input(event):
	if event is InputEventMouseMotion and GlobalScript.GamePaused == false:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x,deg_to_rad(-89),deg_to_rad(89))
	if event.is_action_pressed("Attack"):
		var DetectedItems = $Head/Area3D.get_overlapping_bodies()
		print(DetectedItems)
		for i in DetectedItems:
			if i is CharacterBody3D and i.has_meta("Enemy") and i.get_meta("Enemy") == true: 
				print("Enemy: ", i)
				i.take_damage(100)
		
		

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("Left", "Right", "Forward", "Backward")
	direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta*lerp_speed)
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
