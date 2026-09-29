extends Node2D
class_name MoveTarget

@export var connections: Array[MoveTarget] 
@export var sprite: Sprite2D
@export var sabotage_sprite: Sprite2D
@export var sabotage_timer: Timer

var enabled: bool = false
var occupant: Group
var sabotage_visible: bool = false

func _process(delta: float) -> void:
	if GameState.in_selected_range(self):
		sprite.visible = true
		enabled = true
		return
	if GameState.is_getting_sabotaged(self):
		if sabotage_timer.is_stopped():
			sabotage_sprite.visible = !sabotage_sprite.visible
			sabotage_timer.start()
		return
	if sabotage_sprite:
		sabotage_sprite.visible = false
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
