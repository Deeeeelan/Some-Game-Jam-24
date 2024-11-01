extends CharacterBody3D

@onready var head = $Head
@export var Player: Node3D

@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5

@export var max_health = 100
@export var health = 100
@export var isDead = false

@export var lerp_speed = 10

var direction = Vector3.ZERO

func death():
	# Handle death animation etc.
	print(self, " has died")
	isDead = true

func take_damage(damage):
	health -= damage
	if health <= 0:
		death()



func Jump():
	velocity.y = JUMP_VELOCITY
	
func melee():
	var DetectedItems = $Melee.get_overlapping_bodies()

	for i in DetectedItems:
		if i is CharacterBody3D and i.get_meta("Player") == true: 
			print("Player: ", i)
			i.take_damage(1)

func _ready() -> void:
	$EnemyAttackTick.timeout.connect(melee)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
	#	velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var angleToPlayer = self.position.direction_to(Player.position)
	var input_dir = Vector2(0,0)
	var NormDir = angleToPlayer #(transform.basis * Vector3(angleToPlayer.x, 0, angleToPlayer.y)).normalized()
	direction = lerp(direction,NormDir,delta*lerp_speed)
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	if not isDead:
		move_and_slide()
	
	# Just makes the enemy jump when velocity is lost. Likely hitting an obsticle. Temporary
	if is_on_floor() and velocity.length() < 0.01:
		Jump()
