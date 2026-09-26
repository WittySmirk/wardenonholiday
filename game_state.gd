extends Node

var selected_guard: Gaurd = null
	
func set_selected_target(target: Vector2):
	if selected_guard != null:
		selected_guard.set_movement_target(target)
		print("set target:", target)
#
## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
