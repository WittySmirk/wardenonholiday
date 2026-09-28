extends Node
var selected_guard: Guard = null
const GUARD_SCENE = preload("res://guard.tscn")

# Signal emitter for other nodes when GameState changes
signal state_changed(new_state)

var guard_kill_count = 0
var inmate_kill_count = 0
var objectives_sabotaged = 0

@export var sabotage_nodes: Array[MoveTarget] = []

# Game States
enum States { START, DAY, NIGHT, LOSE }
var current_state = States.DAY:
	set(value):
		current_state = value
		state_changed.emit(current_state)

func set_selected_target(target: MoveTarget, doSplit: bool):
	if selected_guard != null:
		if selected_guard.current_node.connections.find(target) != -1:
			#Guards cannot move to other guards spaces
			#if target.occupant != null and target.occupant.groupType == Group.GroupType.GUARD:
				#return
			
			#If split is true, split the guard force in half and send half to the new tile
			if doSplit:
				if target.occupant != null and target.occupant.groupType == Group.GroupType.INMATE:
					return
				
				selected_guard.splitting = true
				selected_guard.cooldown_timer.start(selected_guard.base_cooldown + (selected_guard.variable_cooldown_per * selected_guard.quantity))
				
				var split_quantity = floor(selected_guard.quantity / 2)
				if split_quantity <= 0:
					return
				
				selected_guard.quantity -= split_quantity
				selected_guard.update_animation()
				print("Selected guard quantity: ", selected_guard.quantity)
				
				var new_guard = GUARD_SCENE.instantiate()
				new_guard.quantity = split_quantity
				print("New guard quantity: ", new_guard.quantity)
				
				new_guard.previous_node = selected_guard.current_node
				selected_guard.get_parent().add_child(new_guard)
				
				new_guard.global_position = selected_guard.global_position
				
				var direction = selected_guard.global_position.direction_to(target.global_position)
				new_guard.global_position += direction * 50.0
				
				new_guard.nav_agent.set_target_position(target.global_position)
				new_guard.target = target
				
				
				selected_guard = null
				return
			
			selected_guard.set_movement_target(target)
			selected_guard = null
		else:
			print("cannot set this target")

func in_selected_range(t: MoveTarget):
	if selected_guard and selected_guard.current_node:
		if selected_guard.current_node.connections.find(t) != -1 and t != selected_guard.current_node:
			return true
	return false

## Switch from Day state to Night state
func change_game_state(state: States):
	print("Changing gamestate to: ", get_state_name(state))
	current_state = state

## Get human readable state enum
func get_state_name(state: States) -> String:
	return States.keys()[state]
	
## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Tell all nodes starting state
	state_changed.emit(current_state)

func initialize_sabotage_nodes(nodes):
	sabotage_nodes.clear()

	for node in nodes:
		if node is MoveTarget:
			sabotage_nodes.append(node)

## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
