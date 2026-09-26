extends CharacterBody2D
class_name Gaurd

var target: MoveTarget
var movement_delta: float
@export var movement_speed: float = 50.0
@export var nav_agent: NavigationAgent2D
@export var current_node: MoveTarget
@export var cooldown_timer: Timer

func _ready() -> void:
	nav_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	current_node.enabled = false
	nav_agent.path_desired_distance = 4.0
	nav_agent.target_desired_distance = 4.0

func set_movement_target(movement_target: MoveTarget):
	nav_agent.set_target_position(movement_target.global_position)
	target = movement_target

func _physics_process(delta):
	# Do not query when the map has never synchronized and is empty.
	if NavigationServer2D.map_get_iteration_id(nav_agent.get_navigation_map()) == 0:
		return
	if (nav_agent.is_navigation_finished() or nav_agent.is_target_reached()) and target:
		current_node = target
		target = null
		cooldown_timer.start()

	var next_path_position: Vector2 = nav_agent.get_next_path_position()
	var new_velocity: Vector2 = global_position.direction_to(next_path_position) * movement_speed
	
	var distance_to_target = global_position.distance_to(next_path_position)
	
	if distance_to_target < (movement_speed * delta):
		new_velocity = global_position.direction_to(next_path_position) * (distance_to_target / delta)
	
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)

func _on_velocity_computed(safe_velocity: Vector2):
	velocity = safe_velocity
	move_and_slide()

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if cooldown_timer.is_stopped():
				GameState.selected_guard = self
				print("guard selected")
			else:
				print("on cooldown")
