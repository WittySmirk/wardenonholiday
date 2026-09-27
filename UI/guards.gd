extends CharacterBody2D


const SPEED = 20.0
const JUMP_VELOCITY = -100.0
const GRAVITY = Vector2(0.0, 750)
const LEFT_THRESHOLD_POS = -35
const RIGHT_THRESHOLD_POS = 400

var direction = 1

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += GRAVITY * delta
		print(get_gravity())

	# Handle jump
	if is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	change_directions()	
	
	move_and_slide()

## Handle animation loop for hopping left and right
func change_directions():
	position = self.position
	if position.x > RIGHT_THRESHOLD_POS:
		direction = -1
	elif position.x < LEFT_THRESHOLD_POS:
		direction = 1
