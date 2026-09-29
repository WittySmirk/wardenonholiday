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
	

# Public functions for this class
	# Returns false when guards cannot be allocated, true if successful
func decrement_counter(decrement_amt: int) -> bool:
	if guard_count >= decrement_amt:
		guard_count = guard_count - decrement_amt
		label.text = str(guard_count)
		return true
	return false

# Returns current number of guards left
func get_count() -> int:
	return guard_count
	
# PRIVATE stuff
# Handle state change
func _on_state_change(state: GameState.States):
	if state == GameState.States.DAY:
		self.visible = true
		guard_count = number_of_guards
	else:
		self.visible = false
