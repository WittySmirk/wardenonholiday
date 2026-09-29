extends Control
class_name GuardCounter

# The count of guards
@export var number_of_guards: int

@onready var label: Label = $Label

# Number of guards remaining to distribute
var guard_count: int = number_of_guards

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initialize guard count
	guard_count = number_of_guards
	# Disappear during other states
	if (GameState.current_state != GameState.States.DAY):
		self.visible = false
	GameState.state_changed.connect(_on_state_change)
	label.text = str(guard_count)
	
	# Set counter update
	GameState.set_guard_count(number_of_guards)
	GameState.guard_count_signal.connect(_on_guard_count_signal)
	
	
# PRIVATE stuff
# Handle state change
func _on_state_change(state: GameState.States):
	if state == GameState.States.DAY:
		self.visible = true
		GameState.set_guard_count(number_of_guards)
	else:
		self.visible = false

# Change counter when signal is received
func _on_guard_count_signal(amount: int):
	guard_count = amount
	label.text = str(amount)
