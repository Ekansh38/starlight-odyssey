extends CharacterBody2D

@export var speed: float = 300.0
@export var shoot_cooldown: float = 1.0
@export var bullet_scene: PackedScene
@export var player_path: NodePath

var player: Node2D
var chase_mode: bool = false
var target_direction: Vector2 = Vector2.RIGHT

func _ready():
	player = get_node(player_path)
	$RandomMovementTimer.start()
	$ShootTimer.wait_time = shoot_cooldown
	$ShootTimer.start()

func _physics_process(delta):
	if chase_mode and is_instance_valid(player):
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		rotation = direction.angle()
	else:
		velocity = target_direction * speed * 0.7  # slower patrol speed
		rotation = target_direction.angle()


	move_and_slide()

func shoot_at_player():
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position
	var direction = (player.global_position - global_position).normalized()

	if "vel" in bullet:
		bullet.vel = direction * Globals.bullet_speed


	get_tree().current_scene.add_child(bullet)


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Ship"):
		chase_mode = true


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Ship"):
		chase_mode = false


func _on_random_movement_timer_timeout() -> void:
	if not chase_mode:
		target_direction = Vector2.RIGHT.rotated(randf() * TAU)


func _on_shoot_timer_timeout() -> void:
	if chase_mode and is_instance_valid(player):
		shoot_at_player()
