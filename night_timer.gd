extends Label

@export var timer: Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState.state_changed.connect(_state_change_callback)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if GameState.current_state == GameState.States.NIGHT:
		self.visible = true
		var	time_left_seconds: float = timer.time_left
		var seconds_left: int = int(time_left_seconds) % 60
		var minutes_left: int = int(time_left_seconds / 60)
		self.text = "%02d:%02d" % [minutes_left, seconds_left]
		
		# Change state when timer runs out
		if minutes_left == 0 && seconds_left == 0:
			timer.stop()
			GameState.change_game_state(GameState.States.DAY)

# State change callback
# If state is NIGHT, make timer appear and start timer
func _state_change_callback(state: GameState.States):
	if state == GameState.States.NIGHT:
		self.visible = true
		self.timer.start()
	else:
		self.visible = false
		if !timer.is_stopped():
			timer.stop()
			
