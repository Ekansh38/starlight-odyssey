extends Node2D

var bullet_scene: PackedScene = preload("res://scenes/bullet.tscn")
var bullet_speed = 1200

func _on_ship_shoot(mouse_pos: Vector2, ship_pos: Vector2) -> void:
	var angle_offset = randf_range(-0.05, 0.05)
	var bullet_direction = (mouse_pos - ship_pos).normalized().rotated(angle_offset)
	var bullet = bullet_scene.instantiate()
	bullet.global_position = ship_pos
	bullet.vel = bullet_direction * bullet_speed
	$Bullets.add_child(bullet)

func _ready():
	var cursor = preload("res://assets/crosshair066.png")
	Input.set_custom_mouse_cursor(cursor, Input.CURSOR_ARROW, Vector2(0.1, 0.1))
