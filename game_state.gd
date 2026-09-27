extends Node

# Signal emitter for other nodes when GameState changes
signal state_changed(new_state)

# Game States
enum States { START, DAY, NIGHT, LOSE }
var current_state = States.DAY:
	set(value):
		current_state = value
		state_changed.emit(current_state)

var selected_guard: Gaurd = null
	
func set_selected_target(target: MoveTarget):
	if selected_guard != null:
		if selected_guard.current_node.connections.find(target) != -1:
			selected_guard.set_movement_target(target)
			selected_guard = null
		else:
			print("cannot set this target")

func in_selected_range(t: MoveTarget):
	if selected_guard and selected_guard.current_node.connections.find(t) != -1 and t != selected_guard.current_node:
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


## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
