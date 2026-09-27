extends Group
class_name Inmate

#TODO LIST OF BUGS
#Roaming gets blocked, doesnt move anymore, when it is unblocked it moves again
#Sabotaging retreat path is bogus when it is blocked (returns [] so knows there is no possible path)
#Same for escape
#If there are no more sabotage nodes it crashes



var target: MoveTarget
var movement_delta: float
@export var movement_speed: float = 50.0 
@export var current_node: MoveTarget
@onready var cooldown_timer = $CooldownTimer
@onready var nav_agent = $NavigationAgent2D

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


func _ready() -> void:
	#Connect nav agent and initialize
	quantity = 4
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


func roam():
	print("roaming")
	
	var next_node = null
	
	for node in current_node.connections:
		if node.occupant == null || node.occupant.groupType == GroupType.INMATE:
			next_node = node
			break
	
	if next_node != null:
		current_node.occupant = null
		
		nav_agent.set_target_position(next_node.global_position)
		target = next_node
	
func check_for_adjacent_guard() -> bool:
	for neighbor in current_node.connections:
		if neighbor.occupant != null:
			if neighbor.occupant.groupType == GroupType.GUARD and neighbor.occupant != guard_to_avoid:
				print("going to fight")
				nav_agent.set_target_position(neighbor.global_position)
				initiated_fight = true
				target = neighbor
				return true
	
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
	path.clear()
	guard_to_avoid = guard
	cooldown_timer.stop()
	
	#Return to the tile where the guard was spotted from
	if inmates_initiated:
		print("Inmates initiated")
		if current_node != null:
			path.append(current_node)
			
		if previous_node != null:
			path.append(previous_node)
	else:
		print("Inmates did not initiate")
		print("Retreat node: ", previous_node)
		if previous_node != null:
			path.append(previous_node)
	
	# Start following the path
	current_path_index = 0
	
	if path.is_empty():
		#TODO kill the inmates
		print("Inmate trapped")
		retreating = false
		fighting = false
		return
	
	current_node.occupant = null
	
	var next_node = path[current_path_index]
	nav_agent.set_target_position(next_node.global_position)
	target = next_node
	current_path_index += 1


func _physics_process(delta):
	# Do not query when the map has never synchronized and is empty.
	if NavigationServer2D.map_get_iteration_id(nav_agent.get_navigation_map()) == 0:
		return
		
	#If the current path is finished, set the node states and start the cooldown timer
	if (nav_agent.is_navigation_finished() or nav_agent.is_target_reached()) and target:
		#Reached the target
		previous_node = current_node
		current_node = target
		target.occupant = self
		target = null
		
		#Check if this was the final retreat node
		if retreating and current_path_index >= path.size():
			retreating = false
			fighting = false
			path.clear()
			current_path_index = 1
			print("humbled")
			inmateType = inmateTypes.ROAMING
		
		if retreating:
			cooldown_timer.start(0.5)
		else:
			cooldown_timer.start(5)
		
		if current_path_index >= path.size() and inmateType == inmateTypes.SABOTAGING:
			sabotaging = true
			#TODO sabotage
	
	if cooldown_timer.is_stopped() and target == null:
		print(self.quantity)
		
		#Check if there are any guards nearby to fight
		if not retreating:
			if check_for_adjacent_guard():
				return
		
		if retreating:
			#If still following a retreat path, get the next position
			if current_path_index < path.size():
				current_node.occupant = null
				
				var next_node = path[current_path_index]
				nav_agent.set_target_position(next_node.global_position)
				initiated_fight = false
				target = next_node
				current_path_index += 1
				return
		
		if sabotaging:
			sabotaging = false
			sabotageNodes.erase(current_sabotage_node)
			#TODO Change something after sabotage
		
		#Keep following the defined path
		if not path.is_empty() and current_path_index < path.size():
			print("code ran")
			current_node.occupant = null

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
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider is Group:
			if collider.groupType == GroupType.GUARD:
				if not fighting:
					fighting = true
					collider.fighting = true
					InteractionHandler.fight(collider, self, initiated_fight)
			elif collider.groupType == GroupType.INMATE:
				#Merge with other inmate group
				#Prevent both trying to merge into each other
				if get_instance_id() < collider.get_instance_id():
					self.quantity += collider.quantity
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
