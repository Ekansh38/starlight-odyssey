extends Control

@export var return_scene: PackedScene = preload("res://scenes/inside_bar.tscn")

@export var warning_time: int   = 5          # seconds left to start warning
@export var shake_amplitude: float = 5.0      # max px offset while shaking
@export var shake_freq: float      = 30.0     # how “fast” it jitters (higher = more change)
@export var normal_color: Color    = Color(1,1,1)
@export var warning_color: Color   = Color(1,0.1,0.1)

@onready var timer: Timer = $Timer
@onready var label: Label = $Label

var _base_pos: Vector2
var _warning_active := false
var _time_accum := 0.0

func _ready() -> void:
	_base_pos = label.position
	if timer.is_stopped():
		timer.start()
	_update_label()
	if not timer.timeout.is_connected(_on_timer_timeout):
		timer.timeout.connect(_on_timer_timeout)

func _process(delta: float) -> void:
	_update_label()
	_handle_warning(delta)

func _update_label() -> void:
	var remaining := int(ceil(timer.time_left))
	var minutes  := remaining / 60
	var seconds  := remaining % 60
	label.text = "%02d:%02d" % [minutes, seconds]

func _handle_warning(delta: float) -> void:
	var remaining := timer.time_left
	var should_warn := remaining > 0.0 and remaining <= warning_time

	if should_warn and not _warning_active:
		_warning_active = true
		# apply warning style
		label.add_theme_color_override("font_color", warning_color)
	elif not should_warn and _warning_active:
		_warning_active = false
		# reset style & position
		label.add_theme_color_override("font_color", normal_color)
		label.position = _base_pos

	if _warning_active:
		_time_accum += delta * shake_freq
		# random-ish jitter using sin/cos with time and some randomness
		var ox = sin(_time_accum + randf()*10.0) * shake_amplitude
		var oy = cos(_time_accum * 1.13 + randf()*10.0) * shake_amplitude
		label.position = _base_pos + Vector2(ox, oy)

func _on_timer_timeout() -> void:
	label.text = "00:00"
	# Ensure we clear shake & set final state
	_warning_active = false
	label.add_theme_color_override("font_color", normal_color)
	label.position = _base_pos
	Globals.did_play_bar_game = true
	Globals.bar_game_score = int($"../Score".text)
	TransitionLayer.change_scene(return_scene)
