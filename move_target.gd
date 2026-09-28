extends Node2D
class_name MoveTarget

@export var connections: Array[MoveTarget] 
@export var sprite: Sprite2D
var enabled: bool = false
var occupant: Group

func _process(delta: float) -> void:
	if GameState.in_selected_range(self):
		sprite.visible = true
		enabled = true
		return
	sprite.visible = false
	enabled = false

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if enabled:
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				GameState.set_selected_target(self, false)
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				GameState.set_selected_target(self, true)
func set_enabled(b: bool) -> void:
	enabled = b
