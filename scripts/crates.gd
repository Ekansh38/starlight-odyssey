extends Node2D

@export var crate_scene: PackedScene
@export var player_path: NodePath
@export var spawn_distance_min: float = 1500.0
@export var spawn_distance_max: float = 2500.0
@export var spawn_interval: float = 5.0
@export var crate_speed_range: Vector2 = Vector2(100, 200)

@onready var player: Node2D = $"../Ship"
var _spawn_timer := 0.0

func _process(delta):
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		var value = randi()
		var first_two_digits = int(str(value).substr(0, 2))
		value = first_two_digits / 100.0
		if value >= 0.8:
			_spawn_crate()
		_spawn_timer = spawn_interval
		

func _spawn_crate():
	var angle = randf() * TAU
	var dist = randf_range(spawn_distance_min, spawn_distance_max)
	var spawn_pos = player.global_position + Vector2(cos(angle), sin(angle)) * dist

	var crate = crate_scene.instantiate()
	crate.global_position = spawn_pos

	var to_player = (player.global_position - spawn_pos).normalized()
	var speed = randf_range(crate_speed_range.x, crate_speed_range.y)
	crate.set_velocity(to_player * speed)

	add_child(crate)
