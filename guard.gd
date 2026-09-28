extends Group
class_name Guard

var target: MoveTarget
var movement_delta: float
@export var movement_speed: float = 50.0
@onready var nav_agent = $NavigationAgent2D
@export var current_node: MoveTarget
@onready var cooldown_timer = $Timer
@onready var animated_sprite = $AnimatedSprite2D

#AI variables
var previous_node: MoveTarget
var previous_previous_node: MoveTarget
var retreat_path: Array[MoveTarget] = []
var retreating = false


func _ready() -> void:
	quantity = randi_range(1, 5)
	
	nav_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	current_node.enabled = false
	nav_agent.path_desired_distance = 4.0
	nav_agent.target_desired_distance = 1.0

func set_movement_target(movement_target: MoveTarget):
	nav_agent.set_target_position(movement_target.global_position)
	print("Target Position: %s" % movement_target.global_position)
	target = movement_target

func retreat(inmates_initiated: bool):
	retreating = true
	print("Guard retreating")
	
	retreat_path.clear()
	
	#Decide what spaces to move to based on whether guard or inmate initiated
	if !inmates_initiated:
		if current_node != null:
			retreat_path.append(current_node)
			
		if previous_node != null:
			retreat_path.append(previous_node)
	else:
		print("code ran")
		if previous_node != null:
			retreat_path.append(previous_node)
		
		if previous_previous_node != null:
			retreat_path.append(previous_previous_node)
	
	if retreat_path.is_empty():
		#TODO Kill guards
		print("Guard trapped")
		return
	
	
	current_node.occupant = null
	
	target = retreat_path[0]
	nav_agent.set_target_position(target.global_position)
	retreat_path.remove_at(0)

func _physics_process(delta):
	# Do not query when the map has never synchronized and is empty.
	if NavigationServer2D.map_get_iteration_id(nav_agent.get_navigation_map()) == 0:
		return
	if (nav_agent.is_navigation_finished() or nav_agent.is_target_reached()) and target:
		previous_previous_node = previous_node
		previous_node = current_node
		current_node = target
		target.occupant = self
		target = null
		
		if retreating:
			cooldown_timer.start(0.5)
		else:
			cooldown_timer.start(0.5)
	
	if cooldown_timer.is_stopped() and target == null:
		
		#Continue retreating if there are still nodes in the retreat path
		if retreating and not retreat_path.is_empty():
			current_node.occupant = null
			
			target = retreat_path[0]
			retreat_path.remove_at(0)
			
			nav_agent.set_target_position(target.global_position)
			return
		
		#Finished retreating
		if retreating:
			retreating = false
			fighting = false
			
		if fighting:
			return

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
	
	if velocity.length() > 0:
		if quantity >= 3:
			animated_sprite.play("moving_large")
		elif quantity >= 2:
			animated_sprite.play("moving_medium")
		else:
			animated_sprite.play("moving_small")
	else:
		if quantity >= 3:
			animated_sprite.play("idle_large")
		elif quantity >= 2:
			animated_sprite.play("idle_medium")
		else:
			animated_sprite.play("idle_small")
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider is Group:
			if collider.groupType == GroupType.INMATE:
				if not fighting:
					fighting = true
					collider.fighting = true
					InteractionHandler.fight(self, collider, !initiated_fight)
				return

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			print(cooldown_timer)
			if cooldown_timer.is_stopped()  and target == null:
				GameState.selected_guard = self
