

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

const mouse_sens = 0.25

var lerp_speed = 10

var direction = Vector3.ZERO

func _physics_process(delta: float) -> void:
	# Add the gravity.

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
	#	velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta*lerp_speed)
	if direction:
	else:
