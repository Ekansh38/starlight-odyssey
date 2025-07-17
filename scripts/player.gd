extends CharacterBody2D

@export var friction := 8.0
@export var SPEED    := 5000.0
@export var MAX_SPEED:=  800.0

@export var walk_energy_per_second := 1.0

var vel: Vector2 = Vector2.ZERO
var acc: Vector2 = Vector2.ZERO
var input_dir: Vector2 = Vector2.ZERO
var last_dir: String = "down"

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D        = $PlayerSprite

func _physics_process(delta: float) -> void:
	input_dir = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down")  - Input.get_action_strength("up")
	)
	
	if input_dir != Vector2.ZERO and Globals.player_energy > 0.0:
		var drain := walk_energy_per_second * delta
		Globals.player_energy = max(Globals.player_energy - drain, 0.0)

	
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
