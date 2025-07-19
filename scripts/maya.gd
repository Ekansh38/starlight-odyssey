extends NPC


func _ready() -> void:
	timeline = load("res://Timelines/Mayannaise.dch")
	timeline_name = "mayannaise"
	ui = get_node(ui_path)
	Dialogic.signal_event.connect(DialogicSignal)
	
	
@export var move_speed: float = 100.0
@export var stop_distance: float = 4.0   # how close is “arrived”

var move_target: Vector2
var moving: bool = false

func move_to(pos: Vector2) -> void:
	move_target = pos
	moving = true

func _physics_process(delta: float) -> void:
	if not moving:
		return

	var to_target: Vector2 = move_target - global_position
	var dist: float = to_target.length()

	if dist <= stop_distance:
		_finish_movement()
		return

	var max_step: float = move_speed * delta
	var step: float = min(max_step, dist)
	var direction: Vector2 = to_target / dist   # normalized
	var motion: Vector2 = direction * step

	var collision := move_and_collide(motion)
	if collision:
		_finish_movement()
		return

	if (move_target - global_position).length() <= stop_distance:
		_finish_movement()

func _finish_movement() -> void:
	moving = false
	velocity = Vector2.ZERO
