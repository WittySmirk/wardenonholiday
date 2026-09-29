extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioPlayer.play_crt_start_up()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _pressed():
	# Change scene
	get_parent().visible = false
