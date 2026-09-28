extends Group
class_name Inmate


var target: MoveTarget
var movement_delta: float

@export var engage_probability: float = 0.5
@export var split_probability: float = 0.2
@export var sabotaging_inmate_percentage: float = 0.66

@export var movement_speed: float = 50.0
@export var base_cooldown: float = 8.0
@export var variable_cooldown_per: float = 0.25
@export var sabotage_cooldown: float = 30.0
@export var current_node: MoveTarget


@onready var cooldown_timer = $Timer
@onready var nav_agent = $NavigationAgent2D
@onready var animated_sprite = $AnimatedSprite2D
@onready var label = $Label
@onready var collision_shape = $CollisionShape2D

#AI variables
enum inmateTypes {ROAMING, SABOTAGING}
var inmateType
var desiredPosition
var current_path_index = 1
var path: Array
var sabotaging = false
var current_sabotage_node: MoveTarget
var guard_to_avoid: Guard

var previous_node: MoveTarget
var retreating = false


func calculate_probability(chance_of_success: float) -> bool:
	return randf() < chance_of_success



func _ready() -> void:
	#Connect nav agent and initialize
	quantity = randi_range(15, 25)
	
	nav_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	nav_agent.path_desired_distance = 4.0
	nav_agent.target_desired_distance = 4.0
	
	if current_node:
		current_node.enabled = false
	
	#Decide the enemy type this group is
	if calculate_probability(sabotaging_inmate_percentage):
		inmateType = inmateTypes.SABOTAGING
		print("SABOTAGING")
		sabotage()
	else:
		inmateType = inmateTypes.ROAMING
		print("ROAMING")
		roam()



func rememberNodes() -> void:
	if current_node:
		current_node.occupant = null
		previous_node = current_node
		current_node = null



func roam():
	print("roaming")
	var valid_nodes: Array[MoveTarget] = []
	if current_node:
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



func sabotage():
	if path.is_empty() and not GameState.sabotage_nodes.is_empty():
		print(GameState.sabotage_nodes)
		var node_index = randi_range(0, GameState.sabotage_nodes.size() - 1)
		var target_node = GameState.sabotage_nodes[node_index]
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



func split():
	cooldown_timer.start(base_cooldown + (variable_cooldown_per * quantity))
	
	var split_quantity = floor(quantity / 2)
	quantity -= split_quantity
	
	#Update animation for new quantity
	update_animation()
	
	#Instantiate new inmate
	var new_inmate = preload("res://inmate.tscn").instantiate()
	new_inmate.quantity = split_quantity
	get_parent().add_child(new_inmate)
	
	new_inmate.global_position = global_position
	new_inmate.current_node = current_node
	
	#Find nodes the split could move to, anywhere that is empty or has another inmate
	var valid_nodes: Array[MoveTarget] = []
	for node in new_inmate.current_node.connections:
		if node.occupant == null or node.occupant.groupType == GroupType.INMATE:
			valid_nodes.append(node)
	
	#If no valid spots found, abort the split
	if valid_nodes.is_empty():
		new_inmate.queue_free()
		quantity += split_quantity
		update_animation()
		return
	
	var target_node = valid_nodes.pick_random()
	
	var direction = global_position.direction_to(target_node.global_position)
	new_inmate.global_position += direction * 50.0
	
	new_inmate.previous_node = new_inmate.current_node
	
	new_inmate.nav_agent.set_target_position(target_node.global_position)
	new_inmate.target = target_node



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
		
		
		#If on a sabotage node, start the cooldown to sabotage
		if current_node in GameState.sabotage_nodes:
			print("Starting sabotage")
			sabotaging = true
			cooldown_timer.start(sabotage_cooldown - (variable_cooldown_per * quantity))
			return
		
		cooldown_timer.start(base_cooldown + (variable_cooldown_per * quantity))
	
	if cooldown_timer.is_stopped() and target == null:
		#Maybe split up the group?
		if quantity > 15 and calculate_probability(split_probability):
			split()
			return
		
		#Check if there are any guards nearby to fight
		if not retreating:
			if check_for_adjacent_guard():
				return
		
		#Finish the sabotage
		if sabotaging:
			sabotaging = false
			GameState.sabotage_nodes.erase(current_sabotage_node)
			GameState.objectives_sabotaged += 1
		
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
	
	update_animation()
	
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
	if startNode == null or endNode == null:
		return []
	
	if startNode == endNode:
		return [startNode]
	
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



func update_animation():
	if velocity.length() > 0:
		if quantity >= 15:
			animated_sprite.play("moving_large")
		elif quantity >= 7:
			animated_sprite.play("moving_medium")
		else:
			animated_sprite.play("moving_small")
	else:
		if quantity >= 15:
			animated_sprite.play("idle_large")
		elif quantity >= 7:
			animated_sprite.play("idle_medium")
		else:
			animated_sprite.play("idle_small")


func _on_area_2d_mouse_entered() -> void:
	$Label.text = str(quantity)
	$Label.visible = true
	$SelectionBox.visible = true


func _on_area_2d_mouse_exited() -> void:
	$Label.visible = false
	$SelectionBox.visible = false
