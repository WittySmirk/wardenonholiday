extends Node2D

@export var guard_counter: GuardCounter		# Custom counter node
@export var area2D: Area2D		# Defines clickable area
@export var guard_scene: PackedScene	# Guard to spawn in
@export var static_guard_scene: PackedScene # Static guard for UI effect
@export var count_label: Label	# Counter label
@export var collision2D: CollisionShape2D # Bounding box for clicking and spawning
@export var move_target_node: MoveTarget

# Number of guards allocated to this node
var _node_guard_count: int = 0
var _random_guard_instances: Array[Node] = []
var _guards: Array[Guard] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set node guard count to 0
	count_label.text = str(_node_guard_count)
	
	# Disappear if not DAY sate
	if (GameState.current_state != GameState.States.DAY):
		self.visible = false
	GameState.state_changed.connect(_on_state_change)


# On a click, add one guard to this room
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var result = guard_counter.decrement_counter(1)
			
			# If false, no more guards are left to allocated
			if (result == false):
				return
				
			_node_guard_count += 1
			count_label.text = str(_node_guard_count)
			_spawn_random_guards()
	
	
# Handle GameState changes
	# Appear during the day, disappear at night
	# At night, spawn in the guards
func _on_state_change(state: GameState.States):
	if (GameState.current_state == GameState.States.DAY):
		self.visible = true
		_node_guard_count = 0
		_clear_all_guards()
	elif (GameState.current_state == GameState.States.NIGHT):
		self.visible = false
		_clear_all_random_guards()
		
		# Spawn the guards
		if (_node_guard_count != 0):
			_spawn_playable_guard()
	else:
		self.visible = false
		_clear_all_random_guards()
		_clear_all_guards()

# Spawns a guard sprite randomly in bounds
func _spawn_random_guards() -> void:
	var shape = collision2D.shape
		
	# Get half-extents of the rectangle
	var extents = (shape as RectangleShape2D).size / 2.0
	
	# Generate a random local position within the rectangle bounds
	var random_x = randf_range(-extents.x, extents.x)
	var random_y = randf_range(-extents.y, extents.y)
	var local_spawn_pos = Vector2(random_x, random_y)
	
	# Convert local position to global world position
	var global_spawn_pos = collision2D.global_position + local_spawn_pos
	
	# Instantiate and add the sprite scene
	var instance = static_guard_scene.instantiate() as Node
	instance.global_position = global_spawn_pos
	get_parent().add_child(instance)
	_random_guard_instances.append(instance)

# Clear all guard sprites
func _clear_all_random_guards() -> void:
	for guard in _random_guard_instances:
		guard.queue_free()
		

# Spawn playable guards for the night
func _spawn_playable_guard():
	if (_node_guard_count != 0):
		var guard = guard_scene.instantiate() as Guard
		guard.current_node = move_target_node
		
		guard.global_position = self.global_position
		guard.quantity = _node_guard_count
		
		get_parent().add_child(guard)
		_guards.append(guard)

# Clear all playable guards
func _clear_all_guards():
	for guard in _guards:
		guard.queue_free()
