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

var camera_tween: Tween

var positions: Array[Vector2] = [
	Vector2(380, 380),
	Vector2(1140, 380),
	Vector2(380, 1140),
	Vector2(1140, 1140)
]

func move_camera(quadrant: int):
	if camera_tween and camera_tween.is_running():
		camera_tween.kill()

	camera_tween = create_tween()
	
	camera_tween.tween_property(
		cam,
		"global_position",
		positions[quadrant-1],
		0.5
	).set_trans(Tween.TRANS_SINE)
	

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
