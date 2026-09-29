extends Node

var click_sound: AudioStreamPlayer
var crt_start_up: AudioStreamPlayer
var crt_static: AudioStreamPlayer
var alert_sound: AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	click_sound = AudioStreamPlayer.new()
	click_sound.stream = preload("res://sounds/click.mp3")
	add_child(click_sound)
	crt_start_up = AudioStreamPlayer.new()
	crt_start_up.stream = preload("res://sounds/crt_startup.mp3")
	add_child(crt_start_up)
	crt_static = AudioStreamPlayer.new()
	var audio: AudioStreamWAV = preload("res://sounds/crt_static.wav")

	audio.loop_mode = AudioStreamWAV.LOOP_FORWARD
	audio.loop_begin = 0
	audio.loop_end = audio.get_length() * audio.mix_rate

	crt_static.stream = audio
	crt_static.volume_db = -15.0

	add_child(crt_static)
	alert_sound = AudioStreamPlayer.new()
	alert_sound.stream = preload("res://sounds/notification_error.mp3")
	add_child(alert_sound)


func start_crt_static() -> void:
	print("Starting CRT static")
	print("Stream: ", crt_static.stream)
	print("Playing before: ", crt_static.playing)

	crt_static.play()

	print("Playing after: ", crt_static.playing)

func play_crt_start_up():
	crt_start_up.play()

func play_alert_sound():
	alert_sound.play()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			click_sound.play()
