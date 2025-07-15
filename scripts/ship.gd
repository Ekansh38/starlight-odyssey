extends CharacterBody2D

@export var thrust_accel_value: float = 400.0
@export var rot_speed: float = 4
@export var linear_damp_ratio: float = 0.989
@export var max_speed_value: float = 1000.0
@export var side_ratio: float = 0.2
@export var steer_boost: float = 1.15
@export var boost_multiplier: float = 2.5
@export var brake_thrust_value: float = 800.0
@export var brake_energy_multiplier: float = 5

var energy_alert_active := false
var damage_alert_active := false

@export var crate_scene: PackedScene
@export var crate_offset_distance: float = 3000.0  
@export var crate_time_to_reach_player: float = 7.0  

var can_self_cannibalize = true

@export var tint_low  : Color = Color(1, 0.5, 0.5)
@export var tint_full : Color = Color(1, 1, 1)  
@export var tint_boost: Color = Color(1, 0.9, 0.2)
@export var collision_damage: float = 5

var can_collide: bool = true

var boost_penalty := 1.3

@export var thrust_drain_seconds : float = 70.0

var energy_drain_rate := 100 / thrust_drain_seconds

signal shoot(mouse_pos: Vector2, ship_pos: Vector2)

var _vel : Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	
	# Shooting logic
	
	if Input.is_action_just_pressed("shoot") and Globals.player_ammo > 0:
		Globals.player_ammo -= 1
		var mouse_pos = get_global_mouse_position()
		var markers = $BulletSpawnPositions.get_children()
		var random_marker = markers[randi() % markers.size()]
		var ship_pos = random_marker.global_position
		
		shoot.emit(mouse_pos, ship_pos)
		
	
	if (Input.is_action_just_pressed("boost") and Input.is_action_pressed("up")) or (Input.is_action_just_pressed("up") and Input.is_action_pressed("boost")):
		$BoostSFX.play()
	if Input.is_action_just_released("boost"):
		$BoostSFX.stop()

	
	
	var thrust_accel = thrust_accel_value
	var max_speed = max_speed_value
	var brake_thrust = brake_thrust_value
		
	var ship_damage = Globals.ship_damage / 80
		
	thrust_accel *= ship_damage
	max_speed *= ship_damage
	brake_thrust *= ship_damage
	
	var w := Input.is_action_pressed("up")
	var a := Input.is_action_pressed("left")
	var d := Input.is_action_pressed("right")
	var boost := Input.is_action_pressed("boost")
	var brake := Input.is_action_pressed("brake")
	
	if (boost and w) or brake:
		$Camera2D.start_shake(0.004)


	var left_pow  := 0.0
	var right_pow := 0.0
	
	if w:
		left_pow  = 1.0
		right_pow = 1.0
		if a and not d: # counter clock wise
			right_pow *= side_ratio
		elif d and not a: # clock wise
			left_pow  *= side_ratio
	else:
		left_pow  = 1.0 if a else 0.0
		right_pow = 1.0 if d else 0.0
	
		
	# Tint and modulate
	
	var boost_mix := 1.0 if boost else 0.0
	
	$Left.visible  = right_pow  > 0.0
	$Right.visible = left_pow > 0.0
	
	var base_left  = tint_low.lerp(tint_full,  left_pow)
	var base_right = tint_low.lerp(tint_full, right_pow)
	
	$Left.modulate  = base_left .lerp(tint_boost, boost_mix)
	$Right.modulate = base_right.lerp(tint_boost, boost_mix)

	# rotation
	
	var rot_dir := (right_pow - left_pow) * rot_speed
	rotation += rot_dir * delta
	
	# Calculating thrust factor
	
	var thrust_factor : float
	var steering := (a != d) and w 
	
	if steering:
		thrust_factor = steer_boost
	else:
		thrust_factor = (left_pow + right_pow) * 0.5 
	
	if boost and thrust_factor > 0.0:
		thrust_factor *= boost_multiplier
		
	
	var this_frame_boost_penalty := boost_penalty if boost else 1.0
	var drain_this_frame := energy_drain_rate * thrust_factor * this_frame_boost_penalty * delta

	# Brake energy calc
	var brake_drain := 0.0
	if brake:
		brake_drain = energy_drain_rate * brake_energy_multiplier * delta

	var total_drain := drain_this_frame + brake_drain

	var available_ratio := 1.0
	if Globals.ship_damage <= 0:
		thrust_factor = 0.0
		brake = false
		total_drain = 0.0
	
	if Globals.player_energy <= 0.01:
		thrust_factor = 0.0
		brake = false
		total_drain = 0.0
	elif total_drain > Globals.player_energy:
		available_ratio = Globals.player_energy / total_drain
		thrust_factor *= available_ratio
		if brake:
			brake_drain *= available_ratio

	Globals.player_energy -= total_drain

	_vel += Vector2.UP.rotated(rotation) * thrust_accel * thrust_factor * delta

	if brake:
		var reverse_dir = -Vector2.UP.rotated(rotation).normalized()
		_vel += reverse_dir * brake_thrust * delta

	_vel *= pow(linear_damp_ratio, delta * 60.0)
	_vel = _vel.limit_length(max_speed)

	velocity = _vel
	move_and_slide()
		
func take_damage(type):
	if type == "medium":
		Globals.ship_damage -= collision_damage
	elif type == "big":
		Globals.ship_damage -= (collision_damage * 2)
	$Camera2D.start_shake(1)
	
func alert_zero_energy():
	$"../UI".change_minor_info("Zero energy. 'G' to self-canibalize")
	await get_tree().create_timer(3).timeout
	$"../UI".change_minor_info("")

func alert_zero_damage():
	$"../UI".change_minor_info("Zero structural integraty. Buy a repair")
	await get_tree().create_timer(3).timeout
	$"../UI".change_minor_info("")

func _process(delta):
	if Globals.player_energy <= 0.1 and not energy_alert_active:
		energy_alert_active = true
		alert_zero_energy()

	if Globals.player_energy > 10.0:
		energy_alert_active = false

	if Globals.ship_damage <= 0 and not damage_alert_active:
		damage_alert_active = true
		alert_zero_damage()

	if Globals.ship_damage > 10.0:
		damage_alert_active = false
	
	if Input.is_action_just_pressed("self-cannibalization") and Globals.max_energy >= 20:
		$"../UI".can_bar_visable(true)
	
	if Input.is_action_pressed("self-cannibalization") and Globals.max_energy >= 20:
		$"../UI".can_bar_update()

	if $"../UI".can_bar_value() >= 100:
		$"../UI".can_bar_visable(false)
		$"../UI".can_bar_reset()
		if can_self_cannibalize:
			self_cannibalize()
			can_self_cannibalize = false
			$SelfCannibalizationTimer.start()
	if Input.is_action_just_released("self-cannibalization"):
		$"../UI".can_bar_reset()
		$"../UI".can_bar_visable(false)

			
	if Input.is_action_just_pressed("eat"):
		eat()

func eat():
	if Globals.food_amount > 0:
		Globals.food_amount -= 1
		Globals.player_energy += Globals.energy_per_food
		$EatingSFX.play(	)
	else:
		$OutOfFoodSFX.play()
		$"../UI".change_info("No food.")
		await get_tree().create_timer(0.5).timeout
		$"../UI".change_info("")

		
func self_cannibalize() -> void:
	var ui = $"../UI"
	var cam = $Camera2D

	ui.change_info("CANNIBALIZED.")
	$CrunchSFX.play()
	Globals.max_energy = max(Globals.max_energy - 20, 10)
	Globals.player_energy = Globals.max_energy
	ui.modulate_screen(Color(1,0.2,0.2,0.2))
	cam.start_shake(5)
	await get_tree().create_timer(1).timeout
	ui.change_info("")
	ui.modulate_screen(Color(1,1,1,0))



func _on_self_cannibalization_timer_timeout() -> void:
	can_self_cannibalize = true
	
	
func change_controll_label(message):
	$LabelHolder/ControlLabel.text = message


func apply_outside_drag(drag_vector: Vector2, strength: float, delta: float) -> void:
	_vel += drag_vector.normalized() * strength * delta
