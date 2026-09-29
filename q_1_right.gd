extends TextureButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState.state_changed.connect(_on_state_change)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_state_change(state: GameState.States):
	if state == GameState.States.START || state == GameState.States.LOSE || state == GameState.States.WIN:
		self.visible = false
	else:
		self.visible = true
