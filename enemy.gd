extends CharacterBody2D

@export var speed: float = 300.0
@export var shoot_cooldown: float = 2
@export var bullet_scene: PackedScene
@export var player_path: NodePath



@onready var mat = $Sprite2D.material as ShaderMaterial
var health = 100

var player: Node2D
var chase_mode: bool = false
var target_direction: Vector2 = Vector2.RIGHT

signal died(drop_position: Vector2)

func _ready():
	var base_mat = $Sprite2D.material
	var my_mat = base_mat.duplicate() as ShaderMaterial
	$Sprite2D.material = my_mat
	my_mat.set_shader_parameter("flash", false)
	
	mat = my_mat	

	player = get_node(player_path)
	$RandomMovementTimer.start()
	$ShootTimer.wait_time = shoot_cooldown
	$ShootTimer.start()
	$HealthBarContainer/HealthBar.value = health
	
	$Sprite2D.visible = false
	$Sprite2D.modulate = Color(1,1,1,0)
	$Sprite2D.visible = true
	
	var tw = create_tween()
	tw.tween_property($Sprite2D, "modulate:a", 1.0, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _physics_process(delta):
	var to_player = player.global_position - global_position
	var distance = to_player.length()
	
	if distance > 30000:
		queue_free()
	
	if chase_mode and is_instance_valid(player):
		var direction = to_player.normalized()

		var desired_distance = 1000.0 
		var distance_tolerance = 300.0 

		if distance > desired_distance + distance_tolerance:
			velocity = direction * speed
		elif distance < desired_distance - distance_tolerance:
			velocity = -direction * speed * 0.8
		else:
			velocity = Vector2.ZERO

		# Face the player no matter what
		rotation = to_player.angle()
	else:
		velocity = target_direction * speed * 0.7  # Patrol

		var target_angle = target_direction.angle()
		rotation = lerp_angle(rotation, target_angle, delta * 2.0)

	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = Vector2.ZERO

func shoot_at_player():
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position
	var direction = (player.global_position - global_position).normalized()
	direction = direction.rotated(randf_range(-0.1, 0.1))
	
	$AnimationPlayer.play("shoot")
	
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
	health -= 25
	if health <= 0:
		death()
	$HealthBarContainer/HealthBar.value = health
	mat.set("shader_parameter/flash", true);
	await get_tree().create_timer(0.1).timeout
	mat.set("shader_parameter/flash", false);

	
	
func death():
	emit_signal("died", global_position)
	queue_free()

	
func start_disapear():
	await get_tree().create_timer(0.2).timeout
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(Callable(self, "queue_free"))
