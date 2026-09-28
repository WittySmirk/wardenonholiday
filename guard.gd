extends Group
class_name Guard

var target: MoveTarget
var movement_delta: float

@export var movement_speed: float = 50.0
@export var base_cooldown: float = 8.0
@export var variable_cooldown_per: float = 1.0
@export var current_node: MoveTarget

@onready var nav_agent = $NavigationAgent2D
@onready var cooldown_timer = $Timer
@onready var animated_sprite = $AnimatedSprite2D

#AI variables
var previous_node: MoveTarget
var previous_previous_node: MoveTarget
var retreat_target: MoveTarget
var retreating = false
var splitting = false
var merging = false


func _ready() -> void:
	update_animation()
	nav_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	nav_agent.path_desired_distance = 4.0
	nav_agent.target_desired_distance = 1.0
	if current_node:
		current_node.occupant = self

func rememberNodes() -> void:
	if current_node:
		current_node.occupant = null
		previous_previous_node = previous_node
		previous_node = current_node
		current_node = null

func set_movement_target(movement_target: MoveTarget):
	rememberNodes()
	nav_agent.set_target_position(movement_target.global_position)
	target = movement_target

func retreat(inmates_initiated: bool, inmate: Inmate):
	retreating = true
	fighting = false
	inmate.fighting = false
	print("Guard retreating")
	
	
	#Decide what spaces to move to based on whether guard or inmate initiate
	if inmates_initiated:
		#Find a node to retreat to that isn't in the direction the attacker came from
		if current_node == null:
			current_node = previous_node
		
		print(current_node.connections)
		for new_node in current_node.connections:
			if new_node != inmate.previous_node and (new_node.occupant == null or new_node.occupant.groupType == GroupType.GUARD):
				retreat_target = new_node
				break
	else:
		#If the guard initiated, deny access and send them back to the node they were just on
		if previous_node:
			retreat_target = previous_node
	
	if retreat_target == null:
		#TODO Kill guards
		print("Guard trapped")
		return
	
	target = retreat_target
	nav_agent.set_target_position(target.global_position)

func _physics_process(delta):
	# Do not query when the map has never synchronized and is empty.
	if NavigationServer2D.map_get_iteration_id(nav_agent.get_navigation_map()) == 0:
		return
	if (nav_agent.is_navigation_finished() or nav_agent.is_target_reached()) and target:
		print("SET")
		current_node = target
		target.occupant = self
		target = null
		
		velocity = Vector2.ZERO
		
		cooldown_timer.start(base_cooldown + (variable_cooldown_per * quantity))
	
	if target == null:
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



func _process(delta: float) -> void:
	update_animation()



func _on_velocity_computed(safe_velocity: Vector2):
	velocity = safe_velocity
	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider is Group:
			if collider.groupType == GroupType.INMATE:
				if not fighting and not retreating and not collider.retreating and target != null:
					fighting = true
					collider.fighting = true
					print("Guard initiated")
					InteractionHandler.fight(self, collider, false)
				return
			elif collider.groupType == GroupType.GUARD:
				var survivor: Guard
				var other: Guard
				
				if get_instance_id() < collider.get_instance_id():
					survivor = self
					other = collider
				else:
					survivor = collider
					other = self
				
				if merging or other.merging:
					return
				
				merging = true
				other.merging = true
				
				print("Survivor: ", survivor)
				print("Other: ", other)
				
				survivor.quantity += other.quantity
				
				if survivor.target != null:
					survivor.target.occupant = survivor
				elif survivor.current_node != null:
					survivor.current_node.occupant = survivor
				
				print("combining, new size: ", survivor.quantity)
				
				survivor.update_animation()
				survivor.merging = false
				other.queue_free()

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if cooldown_timer.is_stopped()  and target == null:
				GameState.selected_guard = self

func update_animation():
	if fighting:
		if quantity >= 5:
			animated_sprite.play("fighting_large")
			return
		elif quantity >= 3:
			animated_sprite.play("fighting_medium")
			return
		else:
			animated_sprite.play("fighting_small")
			return
		
	if velocity.length() > 0:
		if quantity >= 5:
			animated_sprite.play("moving_large")
		elif quantity >= 3:
			animated_sprite.play("moving_medium")
		else:
			animated_sprite.play("moving_small")
	else:
		if quantity >= 5:
			animated_sprite.play("idle_large")
		elif quantity >= 3:
			animated_sprite.play("idle_medium")
		else:
			animated_sprite.play("idle_small")


func _on_area_2d_mouse_entered() -> void:
	$Label.visible = true
	$Label.text = str(quantity)
	$SelectionBox.visible = true


func _on_area_2d_mouse_exited() -> void:
	$Label.visible = false
	$SelectionBox.visible = false
