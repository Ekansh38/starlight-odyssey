extends Node2D

@export var medium_asteroid_scene: PackedScene
@export var big_asteroid_scene: PackedScene
@export var player_path: NodePath
@export var spawn_interval: float = 0.2
@export var spawn_distance_min: float = 1500.0
@export var spawn_distance_max: float = 2500.0
@export var big_chance: float = 0.2
@export var face_chance: float = 0.4



@export var max_asteroids: int   = 60
@export var cleanup_margin: float = 1.3

@onready var player: CharacterBody2D = get_node(player_path)
var _spawn_timer: float = 0.0

func _process(delta: float) -> void:
	var count = get_tree().get_nodes_in_group("Asteroid").size()
	if count > max_asteroids:
		return
	
	var cleanup_dist = spawn_distance_max * cleanup_margin
	for rock in get_tree().get_nodes_in_group("Asteroid"):
		if rock.global_position.distance_to(player.global_position) > cleanup_dist:
			rock.queue_free()
	
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_asteroid()
		_spawn_timer = spawn_interval

func _spawn_asteroid() -> void:
	var spawn_pos: Vector2
	var heading  : Vector2

	var angle = randf() * TAU
	var dist = randf_range(spawn_distance_min, spawn_distance_max)
	spawn_pos = player.global_position + Vector2(cos(angle), sin(angle)) * dist

	if randf() < 0.15:
		# 15% chance: aim at the player
		heading = (player.global_position - spawn_pos).normalized()
	else:
		# 85% chance: random direction
		var random_angle = randf() * TAU
		heading = Vector2(cos(random_angle), sin(random_angle)).normalized()

	var scene = big_asteroid_scene if randf() < big_chance else medium_asteroid_scene
	var rock  = scene.instantiate()
	rock.global_position = spawn_pos
	rock.add_to_group("Asteroid")

	if rock.has_method("set_direction"):
		rock.set_direction(heading)
	elif rock is RigidBody2D:
		rock.linear_velocity = heading * rock.speed
	elif rock.has_variable("dir"):
		rock.dir = heading
	else:
		rock.set("dir", heading)

	add_child(rock)
