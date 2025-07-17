extends Area2D

@export var spawner_path          : NodePath = NodePath("..../AsteroidSpawner")
@export var zone_spawn_interval  : float   = 0.4
@export var zone_dist_min        : float   = 3000.0
@export var zone_dist_max        : float   = 5000.0
@export var zone_big_chance      : float   = 0.3
@export var zone_face_chance     : float   = 0.5
@export var zone_max_asteroids   : int     = 120
@export var zone_cleanup_margin  : float   = 1.2

var _spawner      : Node         = null
var _orig_params  : Dictionary   = {}

func _ready() -> void:
	_spawner = get_node_or_null(spawner_path)
	if not _spawner:
		push_error("AsteroidZone: could not find spawner at %s" % spawner_path)

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("Ship") or not _spawner:
		return

	# only save defaults once
	if _orig_params.size() == 0:
		_orig_params = {
			"spawn_interval":      _spawner.spawn_interval,
			"spawn_distance_min":  _spawner.spawn_distance_min,
			"spawn_distance_max":  _spawner.spawn_distance_max,
			"big_chance":          _spawner.big_chance,
			"face_chance":         _spawner.face_chance,
			"max_asteroids":       _spawner.max_asteroids,
			"cleanup_margin":      _spawner.cleanup_margin
		}

	# apply zone overrides
	_spawner.spawn_interval     = zone_spawn_interval
	_spawner.spawn_distance_min = zone_dist_min
	_spawner.spawn_distance_max = zone_dist_max
	_spawner.big_chance         = zone_big_chance
	_spawner.face_chance        = zone_face_chance
	_spawner.max_asteroids      = zone_max_asteroids
	_spawner.cleanup_margin     = zone_cleanup_margin

func _on_body_exited(body: Node) -> void:
	if not body.is_in_group("Ship") or not _spawner:
		return

	# restore originals (only if we saved them already)
	for key in _orig_params.keys():
		_spawner.set(key, _orig_params[key])

	_orig_params.clear()
