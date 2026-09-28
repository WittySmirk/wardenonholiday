extends AnimatedSprite2D

@onready var timer: Timer = get_parent().get_node("Timer")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not timer.is_stopped():
		var total_time = timer.wait_time
		var time_left = timer.time_left
		var elapsed_percentage = (total_time - time_left) / total_time
		
		self.show()
		
		if elapsed_percentage < 0.125:
			self.frame = 0
		elif elapsed_percentage < 0.25:
			self.frame = 1
		elif elapsed_percentage < 0.375:
			self.frame = 2
		elif elapsed_percentage < 0.5:
			self.frame = 3
		elif elapsed_percentage < 0.625:
			self.frame = 4
		elif elapsed_percentage < 0.75:
			self.frame = 5
		elif elapsed_percentage < 0.875:
			self.frame = 6
		elif elapsed_percentage < 1:
			self.frame = 7
	else:
		self.hide()
	pass
