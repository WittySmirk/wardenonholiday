extends CharacterBody2D

@export var nav_agent : NavigationAgent2D

func _process(delta: float):
	nav_agent.target_position = Vector2(0,0)
	# print(nav_agent.get_next_path_position())

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			print("gaurd clicked")
