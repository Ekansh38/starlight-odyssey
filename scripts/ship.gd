extends CharacterBody2D

@export var thrust_accel_value: float = 700.0
@export var rot_speed: float = 4
@export var linear_damp_ratio: float = 0.989
@export var max_speed_value: float = 1800.0
@export var side_ratio: float = 0.2
@export var steer_boost: float = 1.15
@export var boost_multiplier: float = 2.5
@export var brake_thrust_value: float = 800.0
@export var brake_energy_multiplier: float = 5

@export var scan_energy_cost : float = 15.0
@export var scan_duration    : float = 3.0
@export var scan_zoom        : Vector2 = Vector2(0.015, 0.015)

var is_scanning := false
var can_scan     := true



@onready var cam := $Camera2D

@export var min_zoom := Vector2(0.3, 0.3)
@export var max_zoom := Vector2(0.25, 0.25)
@export var max_speed_for_zoom := 800.0


var energy_alert_active := false
var damage_alert_active := false

@export var crate_scene: PackedScene
@export var crate_offset_distance: float = 3000.0  
@export var crate_time_to_reach_player: float = 7.0  

var zoom_override: Vector2 = Vector2.ZERO
var is_zoom_overridden := false

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

func _ready():
	#$ShadowHolder/ShadowSprite.modulate = Color(0, 0, 0, 0.25)
	if Globals.has_saved_ship_pos:
		global_position = Globals.last_ship_position



func _physics_process(delta: float) -> void:
	
	
	
	# Damage logic, from 75 bellow it is damage1 then 50 bellow damage 2 etc
	
	$Sprite2D.visible = false
	$Damage1.visible = false
	$Damage2.visible = false
	$Damage3.visible = false

	if Globals.ship_damage > 75:
		$Sprite2D.visible = true
	elif Globals.ship_damage > 50:
		$Damage1.visible = true
	elif Globals.ship_damage > 25:
		$Damage2.visible = true
	else:
		$Damage3.visible = true
	
	
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
	
	$Left.visible = false
	$Right.visible = false
	$"../UI".speed_lines_visablity(false)

	$Both.visible = false
	$PowerLight.visible = false
	$PowerLight.energy = 1
	$LeftParticleBoost.emitting = false
	$RightParticleBoost.emitting = false
	
	$LeftParticleThrust.emitting = false
	$RightParticleThrust.emitting = false

	if (w) or (a and d):
		$Both.visible = true
		$PowerLight.visible = true

	elif a:
		$RightParticleThrust.emitting = true
	elif d:
		$LeftParticleThrust.emitting = true
		pass
		
	if not is_zoom_overridden:
		if not boost:
			var target_zoom = min_zoom
			cam.zoom = cam.zoom.lerp(target_zoom, delta * 5.0)
		elif ((w) or (a and d)) and boost:
			var target_zoom = max_zoom
			cam.zoom = cam.zoom.lerp(target_zoom, delta * 5.0)
		elif a:
			$Right.visible = true
		elif d:
			$Left.visible = true
		
	if ((w) or (a and d)) and not boost:
		$AnimationPlayer.play("thrust")
		$RightParticleThrust.emitting = true
		$LeftParticleThrust.emitting = true

	elif ((w) or (a and d)) and boost:
		$AnimationPlayer.play("boost")
		$PowerLight.energy = 1.5
		$PowerLight.texture_scale = 0.35
		$LeftParticleBoost.emitting = true
		$RightParticleBoost.emitting = true
		$"../UI".speed_lines_visablity(true)
	else:
		$AnimationPlayer.stop()
	
	if (boost and w) or brake or (a and d and boost):
		$Camera2D.start_shake(0.007)

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
	
	
	var base_left  = tint_low.lerp(tint_full,  left_pow)
	var base_right = tint_low.lerp(tint_full, right_pow)
	

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
	
	
	var clamped_gravity = -velocity.limit_length(600)  # 600 is the max gravity force

	#$LeftParticleThrust.gravity = $LeftParticleThrust.gravity.lerp(clamped_gravity, delta * 5.0)
	#$RightParticleThrust.gravity = $RightParticleThrust.gravity.lerp(clamped_gravity, delta * 5.0)
	$LeftParticleBoost.gravity = $LeftParticleBoost.gravity.lerp(clamped_gravity, delta * 5.0)
	$RightParticleBoost.gravity = $RightParticleBoost.gravity.lerp(clamped_gravity, delta * 5.0)
	
	move_and_slide()
		
func take_damage(type):
	if type == "medium":
		Globals.ship_damage -= collision_damage
	elif type == "big":
		Globals.ship_damage -= (collision_damage * 2)
	$Camera2D.start_shake(1)
	
func alert_low_energy() -> void:
	var tree = get_tree()
	var ui   = $"../UI"
	if not is_instance_valid(ui):
		return
		
	if not energy_alert_active:
		return
	
	while energy_alert_active:

		ui.change_minor_info("LOW ENERGY WARNING.")
		await tree.create_timer(0.8).timeout

		if not is_instance_valid(ui):
			return

		ui.change_minor_info("")
		await tree.create_timer(0.8).timeout

		if not is_instance_valid(ui):
			return

		if is_instance_valid(ui):
			ui.change_minor_info("")
		


func _process(delta):
	
	
	var ui = $"../UI"

	if Input.is_action_just_pressed("scan") and can_scan and Globals.player_energy >= scan_energy_cost:
		ui.zoom_bar_visable(true)

	if Input.is_action_pressed("scan") and ui.zoom_bar_value() < 100:
		ui.zoom_bar_update()

	if ui.zoom_bar_value() >= 100 and can_scan:
		# commit the scan
		Globals.player_energy -= scan_energy_cost
		can_scan = false
		ui.zoom_bar_visable(false)
		ui.zoom_bar_reset()
		_start_scan()
		

	if Input.is_action_just_released("scan"):
		ui.zoom_bar_visable(false)
		ui.zoom_bar_reset()
	
	if Globals.player_energy <= 20 and not energy_alert_active:
		energy_alert_active = true
		alert_low_energy()
	
	

	if Globals.player_energy > 20.0:
		energy_alert_active = false
		$"../UI".change_minor_info("")

	
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
	Globals.max_energy = max(Globals.max_energy - 10, 10)
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



func override_zoom(target: Vector2):
	is_zoom_overridden = true
	zoom_override = target
	var zoom_tween = create_tween()
	zoom_tween.tween_property(cam, "zoom", target, 2.5).set_trans(Tween.TRANS_SINE)

func clear_zoom_override():
	var zoom_tween = create_tween()
	zoom_tween.tween_property(cam, "zoom", min_zoom, 2.0).set_trans(Tween.TRANS_SINE)
	await zoom_tween.finished
	is_zoom_overridden = false


func _start_scan() -> void:
	$"../UI".change_info("ZOOMING OUT")
	is_scanning = true
	Globals.player_energy -= scan_energy_cost
	override_zoom(scan_zoom)
	$Woosh.play()

	if not is_inside_tree():
		return
	await get_tree().create_timer(2).timeout
	$"../UI".change_info("")

	for rock in get_tree().get_nodes_in_group("Asteroid"):
		rock.visible = false
	set_physics_process(false)

	await get_tree().create_timer(scan_duration).timeout

	clear_zoom_override()
	for rock in get_tree().get_nodes_in_group("Asteroid"):
		rock.visible = true
	set_physics_process(true)
	is_scanning = false
	can_scan = true
