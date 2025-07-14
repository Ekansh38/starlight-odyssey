extends CharacterBody2D

var vel: Vector2 = Vector2.ZERO
var acc: Vector2 = Vector2.ZERO
var dir: Vector2 = Vector2.ZERO

@export var friction := 8.0
@export var SPEED := 5000.0
@export var MAX_SPEED := 800.0

func _physics_process(delta: float) -> void:
	dir = Vector2.ZERO

	if Input.is_action_pressed("left"):
		dir.x -= 1
	if Input.is_action_pressed("right"):
		dir.x += 1
	if Input.is_action_pressed("up"):
		dir.y -= 1
	if Input.is_action_pressed("down"):
		dir.y += 1

	if dir != Vector2.ZERO:
		dir = dir.normalized()
		acc = dir * SPEED
	else:
		acc = Vector2.ZERO

	vel *= 1.0 - (friction * delta)
	vel += acc * delta

	if vel.length() > MAX_SPEED:
		vel = vel.normalized() * MAX_SPEED
	if vel.length() < 1.0:
		vel = Vector2.ZERO

	velocity = vel
	move_and_slide()
