extends Node2D

@onready var cam: Camera2D = $Camera2D
@export var q1_right: TextureButton
@export var q1_down: TextureButton
@export var q2_left: TextureButton
@export var q2_down: TextureButton
@export var q3_right: TextureButton
@export var q3_up: TextureButton
@export var q4_left: TextureButton
@export var q4_up: TextureButton

@onready var blink_timer: Timer = $Timer
@onready var server: MoveTarget = $sabotage_nodes/move_target_server
@onready var caffeteria: MoveTarget = $sabotage_nodes/move_target_cafeteria
@onready var rec_center: MoveTarget = $sabotage_nodes/move_target_rec_center

const alert_arrow = preload("res://sprites/buttons/arrow_alert.png")
const blink_arrow = preload("res://sprites/buttons/alert_arrow_0002.png")
const normal_arrow = preload("res://sprites/buttons/arrow_normal.png")

var camera_tween: Tween
var blink: bool = true

var positions: Array[Vector2] = [
	Vector2(380, 380),
	Vector2(1140, 380),
	Vector2(380, 1140),
	Vector2(1140, 1140)
]

var quadrant: int = 1

func _ready() -> void:
	GameState.initialize_sabotage_nodes($sabotage_nodes.get_children())
	GameState.initialize_suspicion_meter($SuspicionMeter)


func move_camera(q: int):
	if camera_tween and camera_tween.is_running():
		camera_tween.kill()

	camera_tween = create_tween()
	
	camera_tween.tween_property(
		cam,
		"global_position",
		positions[q-1],
		0.5
	).set_trans(Tween.TRANS_SINE)
	quadrant = q

func set_arrow(arrow: TextureButton, sabotaged: bool) -> void:
	if sabotaged:
		arrow.texture_normal = alert_arrow if blink else blink_arrow
	else:
		arrow.texture_normal = normal_arrow

func _process(delta: float) -> void:
	# Update blink state
	if blink_timer.is_stopped():
		blink = !blink
		blink_timer.start()

	# Check sabotage states
	
	var cafe = GameState.is_getting_sabotaged(caffeteria)
	var serv = GameState.is_getting_sabotaged(server)
	var rec = GameState.is_getting_sabotaged(rec_center)

	# Update arrows depending on current quadrant
	match quadrant:
		1:
			set_arrow(q1_right, rec)
			set_arrow(q1_down, serv)

		2:
			set_arrow(q2_left, cafe or serv)
			set_arrow(q2_down, serv)

		3:
			set_arrow(q3_right, rec)
			set_arrow(q3_up, cafe or rec)

		4:
			set_arrow(q4_left, cafe or serv)
			set_arrow(q4_up, cafe or rec)

		

func _on_q_1_right_pressed() -> void:
	q1_right.visible = false
	q1_right.disabled = true
	q1_down.visible = false
	q1_down.disabled = true
	
	q2_left.visible = true
	q2_left.disabled = false
	q2_down.visible = true
	q2_down.disabled = false
	
	move_camera(2)

func _on_q_1_down_pressed() -> void:
	q1_right.visible = false
	q1_right.disabled = true
	q1_down.visible = false
	q1_down.disabled = true
	
	q3_up.visible = true
	q3_up.disabled = false
	q3_right.visible = true
	q3_right.disabled = false
	move_camera(3)


func _on_q_2_down_pressed() -> void:
	q2_left.visible = false
	q2_left.disabled = true
	q2_down.visible = false
	q2_down.disabled = true
	
	q4_up.visible = true
	q4_up.disabled = false
	q4_left.visible = true
	q4_left.disabled = false
	move_camera(4)

func _on_q_2_left_pressed() -> void:
	q2_left.visible = false
	q2_left.disabled = true
	q2_down.visible = false
	q2_down.disabled = true
	
	q1_right.visible = true
	q1_right.disabled = false
	q1_down.visible = true
	q1_down.disabled = false
	move_camera(1)

func _on_q_3_right_pressed() -> void:
	q3_right.visible = false
	q3_right.disabled = true
	q3_up.visible = false
	q3_up.disabled = true
	
	q4_left.visible = true
	q4_left.disabled = false
	q4_up.visible = true
	q4_up.disabled = false
	move_camera(4)


func _on_q_3_up_pressed() -> void:
	q3_right.visible = false
	q3_right.disabled = true
	q3_up.visible = false
	q3_up.disabled = true
	
	q1_right.visible = true
	q1_right.disabled = false
	q1_down.visible = true
	q1_down.disabled = false
	move_camera(1)


func _on_q_4_up_pressed() -> void:
	q4_left.visible = false
	q4_left.disabled = true
	q4_up.visible = false
	q4_up.disabled = true
	
	q2_left.visible = true
	q2_left.disabled = false
	q2_down.visible = true
	q2_down.disabled = false
	move_camera(2)


func _on_q_4_left_pressed() -> void:
	q4_left.visible = false
	q4_left.disabled = true
	q4_up.visible = false
	q4_up.disabled = true
	
	q3_right.visible = true
	q3_right.disabled = false
	q3_up.visible = true
	q3_up.disabled = false
	move_camera(3)
