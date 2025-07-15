extends Node2D

@export var enemy_scene: PackedScene
@export var player_path: NodePath
@export var bullet_scene: PackedScene

@export var spawn_interval: float = 2.0
@export var spawn_distance_min: float = 1000.0
@export var spawn_distance_max: float = 2000.0

@export var max_enemies: int = 10
@export var cleanup_margin: float = 1.3
@export var face_player_chance: float = 0.4
@export var spawn_chance: float = 1

@onready var player := get_node(player_path)
var _spawn_timer: float = 0.0

func _process(delta: float) -> void:
	if not is_instance_valid(player):
		return
	
	# Cleanup old enemies
	var cleanup_dist = spawn_distance_max * cleanup_margin
	for enemy in get_tree().get_nodes_in_group("Enemy"):
		if enemy.global_position.distance_to(player.global_position) > cleanup_dist:
			enemy.queue_free()

	# Limit max enemies
	var count = get_tree().get_nodes_in_group("Enemy").size()
	if count >= max_enemies:
		return
	
	# Countdown to spawn
	_spawn_timer -= delta
	if _spawn_timer <= 0:	
		var value = randi()
		var first_two_digits = int(str(value).substr(0, 2))
		value = first_two_digits / 100.0
		if value <= spawn_chance:

			_spawn_enemy()
			_spawn_timer = spawn_interval

func _spawn_enemy() -> void:
	if not is_instance_valid(player):
		return

	var angle = randf() * TAU
	var dist = randf_range(spawn_distance_min, spawn_distance_max)
	var spawn_pos = player.global_position + Vector2(cos(angle), sin(angle)) * dist

	var direction: Vector2
	if randf() < face_player_chance:
		direction = (player.global_position - spawn_pos).normalized()
	else:
		var rand_angle = randf() * TAU
		direction = Vector2.RIGHT.rotated(rand_angle)

	var enemy = enemy_scene.instantiate()
	enemy.global_position = spawn_pos
	enemy.player_path = player.get_path()
	enemy.bullet_scene = bullet_scene



	if "set_direction" in enemy:
		enemy.set_direction(direction)
	elif "dir" in enemy:
		enemy.dir = direction

	enemy.add_to_group("Enemy")
	add_child(enemy)
