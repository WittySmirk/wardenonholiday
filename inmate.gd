extends Group
class_name Inmate

#TODO LIST OF BUGS
#Roaming gets blocked, doesnt move anymore, when it is unblocked it moves again
#Sabotaging retreat path is bogus when it is blocked (returns [] so knows there is no possible path)
#Same for escape
#If there are no more sabotage nodes it crashes



var target: MoveTarget
var movement_delta: float

@export var engage_probability: float = 0.5
@export var split_probability: float = 0.2

@export var movement_speed: float = 50.0 
@export var current_node: MoveTarget
@onready var cooldown_timer = $Timer
@onready var nav_agent = $NavigationAgent2D
@onready var animated_sprite = $AnimatedSprite2D

#AI variables
enum inmateTypes {ROAMING, ESCAPING, SABOTAGING}
var inmateType
var desiredPosition
var current_path_index = 1
var path: Array
var sabotaging = false
var current_sabotage_node: MoveTarget
var guard_to_avoid: Guard
@export var escapeNodes: Array[MoveTarget]
@export var sabotageNodes: Array[MoveTarget]

var previous_node: MoveTarget
var retreating = false


func calculate_probability(chance_of_success: float) -> bool:
	return randf() < chance_of_success

func _ready() -> void:
	#Connect nav agent and initialize
	quantity = randi_range(1, 15)
	nav_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	current_node.enabled = false
	nav_agent.path_desired_distance = 4.0
	nav_agent.target_desired_distance = 4.0
	
	#Decide the enemy type this group is
	var rand = randi_range(0, 2)
	match rand:
		0:
			inmateType = inmateTypes.ROAMING
			print("ROAMING")
			roam()
		1:
			inmateType = inmateTypes.ESCAPING
			print("ESCAPING")
			escape()
		2:
			inmateType = inmateTypes.SABOTAGING
			print("SABOTAGING")
			sabotage()

func rememberNodes() -> void:
	if current_node:
		current_node.occupant = null
		previous_node = current_node
		current_node = null

func roam():
	print("roaming")

	var valid_nodes: Array[MoveTarget] = []

	for node in current_node.connections:
		if node.occupant == null or node.occupant.groupType == GroupType.INMATE:
			valid_nodes.append(node)

	if not valid_nodes.is_empty():
		var next_node = valid_nodes.pick_random()
		
		rememberNodes()
		nav_agent.set_target_position(next_node.global_position)
		target = next_node
	
func check_for_adjacent_guard() -> bool:
	for neighbor in current_node.connections:
		if neighbor.occupant != null:
			if neighbor.occupant.groupType == GroupType.GUARD and neighbor.occupant != guard_to_avoid:
				if calculate_probability(engage_probability):
					print("going to fight")
					rememberNodes()
					
					nav_agent.set_target_position(neighbor.global_position)
					target = neighbor
					return true
				else:
					print("Don't wanna fight")
					return false
	
	return false


func escape():
	#Find path to escape
	if path.is_empty() and not escapeNodes.is_empty():
		var target_node = escapeNodes[randi_range(0, escapeNodes.size() - 1)]
		path = findBestPath(current_node, target_node, false)
		current_path_index = 1
	
	#If no path was found, just roam until one is
	if path.is_empty():
		roam()

func sabotage():
	if path.is_empty() and not sabotageNodes.is_empty():
		var node_index = randi_range(0, sabotageNodes.size() - 1)
		var target_node = sabotageNodes[node_index]
		current_sabotage_node = target_node
		
		path = findBestPath(current_node, target_node, false)
		current_path_index = 1
	
	if path.is_empty():
		roam()

func retreat(inmates_initiated: bool, guard: Guard):
	retreating = true
	fighting = false
	guard.fighting = false
	guard_to_avoid = guard
	cooldown_timer.stop()
	
	var retreat_target: MoveTarget = null
	
	if !inmates_initiated:
		#Find a node that isn't where the guard came from
		
		#If the current node is null (inmate is currently moving), set its current node to the place it last was
		if current_node == null:
			current_node = previous_node
		
		for new_node in current_node.connections:
			if new_node != guard.previous_node:
				retreat_target = new_node
				break
	else:
		#Guard initiated, so go back to previous node
		print("The inmate chose its previous node")
		print(previous_node)
		print(current_node)
		if previous_node:
			retreat_target = previous_node
	
	if retreat_target == null:
		print("Inmate trapped")
		retreating = false
		return
	
	rememberNodes()
	
	target = retreat_target
	nav_agent.set_target_position(target.global_position)


func _physics_process(delta):
	# Do not query when the map has never synchronized and is empty.
	if NavigationServer2D.map_get_iteration_id(nav_agent.get_navigation_map()) == 0:
		return
		
	#If the current path is finished, set the node states and start the cooldown timer
	if (nav_agent.is_navigation_finished() or nav_agent.is_target_reached()) and target:
		#Reached the target
		current_node = target
		target.occupant = self
		target = null
		
		#Check if this was the final retreat node
		if retreating:
			retreating = false
			fighting = false

		cooldown_timer.start(5)
		
		if current_path_index >= path.size() and inmateType == inmateTypes.SABOTAGING:
			sabotaging = true
			#TODO sabotage
	
	if cooldown_timer.is_stopped() and target == null:
		#Check if there are any guards nearby to fight
		if not retreating:
			if check_for_adjacent_guard():
				return
		
		if retreating:
			#If still following a retreat path, get the next position
			rememberNodes()
			
			var next_node = path[current_path_index]
			nav_agent.set_target_position(next_node.global_position)
			target = next_node
			current_path_index += 1
			return
		
		if sabotaging:
			sabotaging = false
			sabotageNodes.erase(current_sabotage_node)
			#TODO Change something after sabotage
		
		#Keep following the defined path
		if not path.is_empty() and current_path_index < path.size():
			rememberNodes()

			var next_node = path[current_path_index]
			nav_agent.set_target_position(next_node.global_position)
			target = next_node
			current_path_index += 1

		else:
			#Otherwise, make a new path
			path.clear()
			current_path_index = 1

			match inmateType:
				inmateTypes.ROAMING:
					roam()
				inmateTypes.ESCAPING:
					escape()
				inmateTypes.SABOTAGING:
					sabotage()
	
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
		if quantity >= 10:
			animated_sprite.play("moving_large")
		elif quantity >= 5:
			animated_sprite.play("moving_medium")
		else:
			animated_sprite.play("moving_small")
	else:
		if quantity >= 10:
			animated_sprite.play("idle_large")
		elif quantity >= 5:
			animated_sprite.play("idle_medium")
		else:
			animated_sprite.play("idle_small")
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider is Group:
			if collider.groupType == GroupType.GUARD:
				if not fighting and not retreating and not collider.retreating and target != null:
					fighting = true
					collider.fighting = true
					print("Inmate initiated")
					InteractionHandler.fight(collider, self, true)
			elif collider.groupType == GroupType.INMATE:
				if get_instance_id() < collider.get_instance_id():
					self.quantity += collider.quantity
					
					if target != null:
						target.occupant = self
					elif current_node != null:
						current_node.occupant = self
					
					collider.queue_free()
					
			return
	
func findBestPath(startNode: MoveTarget, endNode: MoveTarget, considerGuards: bool) -> Array[MoveTarget]:
	var visited: Dictionary = {startNode: true}
	var queue: Array = [startNode]
	var parent_map: Dictionary = {startNode: null}
	
	while queue.size() > 0:
		var current_node: MoveTarget = queue.pop_front()
		
		for neighbor in current_node.connections:
			if neighbor in visited:
				continue
				
			if considerGuards and neighbor.occupant != null:
				if neighbor.occupant.groupType == GroupType.GUARD:
					print("Guard in the way")
					continue
			
			visited[neighbor] = true
			parent_map[neighbor] = current_node
			queue.append(neighbor)
			
			if neighbor == endNode:
				return reconstructBestPath(parent_map, startNode, endNode)
	return []


func reconstructBestPath(parent_map: Dictionary, startNode: MoveTarget, endNode: MoveTarget) -> Array:
	var path: Array = []
	var current = endNode
	
	while current != null:
		path.append(current)
		current = parent_map[current]
	
	path.reverse()
	return path
