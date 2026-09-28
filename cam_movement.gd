extends Node2D

@onready var cam: Camera2D = $Camera2D

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
	get_node("Camera2D/q1_right").visible = false
	get_node("Camera2D/q1_right").disabled = true
	get_node("Camera2D/q1_down").visible = false
	get_node("Camera2D/q1_down").disabled = true
	
	get_node("Camera2D/q2-left").visible = true
	get_node("Camera2D/q2-left").disabled = false
	get_node("Camera2D/q2_down").visible = true
	get_node("Camera2D/q2_down").disabled = false
	
	move_camera(2)

func _on_q_1_down_pressed() -> void:
	get_node("Camera2D/q1_right").visible = false
	get_node("Camera2D/q1_right").disabled = true
	get_node("Camera2D/q1_down").visible = false
	get_node("Camera2D/q1_down").disabled = true
	
	get_node("Camera2D/q3_up").visible = true
	get_node("Camera2D/q3_up").disabled = false
	get_node("Camera2D/q3_right").visible = true
	get_node("Camera2D/q3_right").disabled = false
	move_camera(3)


func _on_q_2_down_pressed() -> void:
	get_node("Camera2D/q2-left").visible = false
	get_node("Camera2D/q2-left").disabled = true
	get_node("Camera2D/q2_down").visible = false
	get_node("Camera2D/q2_down").disabled = true
	
	get_node("Camera2D/q4_up").visible = true
	get_node("Camera2D/q4_up").disabled = false
	get_node("Camera2D/q4_left").visible = true
	get_node("Camera2D/q4_left").disabled = false
	move_camera(4)

func _on_q_2_left_pressed() -> void:
	get_node("Camera2D/q2-left").visible = false
	get_node("Camera2D/q2-left").disabled = true
	get_node("Camera2D/q2_down").visible = false
	get_node("Camera2D/q2_down").disabled = true
	
	get_node("Camera2D/q1_right").visible = true
	get_node("Camera2D/q1_right").disabled = false
	get_node("Camera2D/q1_down").visible = true
	get_node("Camera2D/q1_down").disabled = false
	move_camera(1)

func _on_q_3_right_pressed() -> void:
	get_node("Camera2D/q3_right").visible = false
	get_node("Camera2D/q3_right").disabled = true
	get_node("Camera2D/q3_up").visible = false
	get_node("Camera2D/q3_up").disabled = true
	
	get_node("Camera2D/q4_left").visible = true
	get_node("Camera2D/q4_left").disabled = false
	get_node("Camera2D/q4_up").visible = true
	get_node("Camera2D/q4_up").disabled = false
	move_camera(4)


func _on_q_3_up_pressed() -> void:
	get_node("Camera2D/q3_right").visible = false
	get_node("Camera2D/q3_right").disabled = true
	get_node("Camera2D/q3_up").visible = false
	get_node("Camera2D/q3_up").disabled = true
	
	get_node("Camera2D/q1_right").visible = true
	get_node("Camera2D/q1_right").disabled = false
	get_node("Camera2D/q1_down").visible = true
	get_node("Camera2D/q1_down").disabled = false
	move_camera(1)


func _on_q_4_up_pressed() -> void:
	get_node("Camera2D/q4_left").visible = false
	get_node("Camera2D/q4_left").disabled = true
	get_node("Camera2D/q4_up").visible = false
	get_node("Camera2D/q4_up").disabled = true
	
	get_node("Camera2D/q2-left").visible = true
	get_node("Camera2D/q2-left").disabled = false
	get_node("Camera2D/q2_down").visible = true
	get_node("Camera2D/q2_down").disabled = false
	move_camera(2)


func _on_q_4_left_pressed() -> void:
	get_node("Camera2D/q4_left").visible = false
	get_node("Camera2D/q4_left").disabled = true
	get_node("Camera2D/q4_up").visible = false
	get_node("Camera2D/q4_up").disabled = true
	
	get_node("Camera2D/q3_right").visible = true
	get_node("Camera2D/q3_right").disabled = false
	get_node("Camera2D/q3_up").visible = true
	get_node("Camera2D/q3_up").disabled = false
	move_camera(3)
