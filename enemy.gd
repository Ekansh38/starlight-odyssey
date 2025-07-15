extends CharacterBody2D

@export var speed: float = 300.0
@export var shoot_cooldown: float = 1.0
@export var bullet_scene: PackedScene
@export var player_path: NodePath

var health = 100

var player: Node2D
var chase_mode: bool = false
var target_direction: Vector2 = Vector2.RIGHT

func _ready():
	player = get_node(player_path)
	$RandomMovementTimer.start()
	$ShootTimer.wait_time = shoot_cooldown
	$ShootTimer.start()
	$HealthBar.value = health

func _physics_process(delta):
	if chase_mode and is_instance_valid(player):
		var to_player = player.global_position - global_position
		var distance = to_player.length()
		var direction = to_player.normalized()

		var desired_distance = 1500.0 
		var distance_tolerance = 300.0 

		if distance > desired_distance + distance_tolerance:
			# Too far → move closer
			velocity = direction * speed
		elif distance < desired_distance - distance_tolerance:
			# Too close → back away
			velocity = -direction * speed * 0.8  # Slightly slower retreat
		else:
			# Within desired range → stop
			velocity = Vector2.ZERO

		# Face the player no matter what
		rotation = to_player.angle()
	else:
		velocity = target_direction * speed * 0.7  # Patrol

		var target_angle = target_direction.angle()
		rotation = lerp_angle(rotation, target_angle, delta * 2.0)

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
		
func take_damage():
	health -= 20
	if health <= 0:
		queue_free()
	$HealthBar.value = health
