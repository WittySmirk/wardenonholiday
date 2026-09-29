extends TextureButton

@onready var label = $Label

var press_offset = Vector2(2, 1)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect callbacks for button press
	button_up.connect(_on_button_up)
	#button_down.connect(_on_button_down)
	pressed.connect(_on_button_down)
	
	# Connect callbacks for GameState change
	GameState.state_changed.connect(_handle_game_state_change)

# IDK why _on_button_up() doesn't work for changing game state
func _pressed():
	# Change GameState
	GameState.change_game_state(GameState.States.DAY)
	
	# Change scene
	get_parent().visible = false
	
# Called when button is pressed
func _on_button_up():
	self.position += press_offset

# Called when button is released
func _on_button_down():
	# Do little press animation
	self.position -= press_offset

# Handle GameState changes
func _handle_game_state_change(state: GameState.States):
	if state == GameState.States.START:
		self.visible = true
	else:
		self.visible = false
		
