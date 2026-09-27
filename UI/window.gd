@tool
extends ColorRect

@export var border_width = 2

# Dynamic sizing
@onready var border_top: ColorRect = $BorderTop
@onready var border_left: ColorRect = $BorderLeft
@onready var border_right: ColorRect = $BorderRight
@onready var border_bottom: ColorRect = $BorderBottom

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_border()

func _update_border() -> void:
	size = Vector2(int(size.x), int(size.y))
	# Top
	border_top.position = Vector2(0, 0)
	border_top.size = Vector2(int(size.x), border_width)
	
	# Bottom
	border_bottom.position = Vector2(0, size.y - border_width)
	border_bottom.size = Vector2(int(size.x), border_width)
	
	# Left
	border_left.position = Vector2(0, border_width)
	border_left.size = Vector2(border_width, size.y - border_width)
	
	# Right
	border_right.position = Vector2(int(size.x - border_width), border_width)
	border_right.size = Vector2(border_width, size.y - border_width)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
