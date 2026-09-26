extends Node

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
	

## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
