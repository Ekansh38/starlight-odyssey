extends CharacterBody2D

@export var friction := 8.0
@export var SPEED    := 5000.0
@export var MAX_SPEED:=  800.0

var drink_held = "none"
@export var can_use_gun = true
@export var fire_cooldown := 0.18   # seconds between shots
var _fire_cd_left := 0.0
signal shoot(direction: Vector2, origin: Vector2)
@export var walk_energy_per_second := 1.0

func _ready():
	$Gun.visible = false

func _point_gun_at_mouse() -> void:
	var gun = $Gun
	var mouse_pos = get_global_mouse_position()
	var to_mouse = mouse_pos - gun.global_position
	gun.rotation = to_mouse.angle() + deg_to_rad(90)

func _process(delta: float) -> void:
	if Globals.player_has_gun and can_use_gun:
		$Gun.visible = true
		_point_gun_at_mouse()

		if _fire_cd_left > 0.0:
			_fire_cd_left -= delta

		if Input.is_action_just_pressed("shoot") and _fire_cd_left <= 0.0:
			_fire_cd_left = fire_cooldown
			_fire_gun()
	else:
		$Gun.visible = false
func _fire_gun() -> void:
	var muzzle := $Gun.get_node_or_null("Muzzle")
	var origin: Vector2 = muzzle.global_position if muzzle else $Gun.global_position

	var dir := (get_global_mouse_position() - origin)
	if dir.length() == 0:
		dir = Vector2.UP
	else:
		dir = dir.normalized()

	emit_signal("shoot", dir, origin)		


func set_controls_enabled(enable: bool) -> void: 
	controls_enabled = enable

var vel: Vector2 = Vector2.ZERO
var acc: Vector2 = Vector2.ZERO
var input_dir: Vector2 = Vector2.ZERO
var last_dir: String = "down"
var controls_enabled: bool = true 

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D        = $PlayerSprite

func change_holdable(image):
	$Holdable.texture = image
	
func change_holdable_frame(frame):
	$Holdable.frame = frame
	if frame == 4:
		$Holdable.modulate = Color("#ca9800")
	else:
		$Holdable.modulate = Color(1,1,1,1)
		
func change_holdable_visible(stat):
	$Holdable.visible = stat


func _physics_process(delta: float) -> void:
	if not controls_enabled:
		velocity = Vector2.ZERO      # stay still while frozen
		return
	input_dir = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down")  - Input.get_action_strength("up")
	)
	

	
	if input_dir != Vector2.ZERO:
		input_dir = input_dir.normalized()
		acc = input_dir * SPEED
	else:
		acc = Vector2.ZERO

	vel = vel * (1.0 - friction * delta) + acc * delta
	if vel.length() > MAX_SPEED:
		vel = vel.normalized() * MAX_SPEED
	if vel.length() < 1.0:
		vel = Vector2.ZERO

	velocity = vel
	move_and_slide()

	_update_animation(input_dir)

func change_controll_label(message):
	$LabelHolder/ControlLabel.text = message


func _update_animation(dir: Vector2) -> void:
	if dir == Vector2.ZERO:
		anim.stop()
		match last_dir:
			"down":
				sprite.frame = 0
			"left":
				sprite.frame = 3
			"right":
				sprite.frame = 6
			"up":
				sprite.frame = 9
	else:
		if abs(dir.x) > abs(dir.y):
			if dir.x > 0:
				anim.play("walk_right")
				last_dir = "right"
			else:
				anim.play("walk_left")
				last_dir = "left"
		else:
			if dir.y > 0:
				anim.play("walk_down")
				last_dir = "down"
			else:
				anim.play("walk_up")
				last_dir = "up"
