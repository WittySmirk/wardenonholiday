extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState.state_changed.connect(_on_state_change)


func _on_state_change(state: GameState.States):
	if (state == GameState.States.WIN):
		self.visible = true
	else:
		self.visible = false
