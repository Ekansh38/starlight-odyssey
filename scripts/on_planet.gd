extends Node2D

var bullet_scene: PackedScene = preload("res://scenes/bullet.tscn")

func _ready():
	print(Globals.did_player_exit_bar)
	if Globals.did_player_exit_bar == true:
		Globals.did_player_exit_bar = false
		$Ysort/Player.global_position = $BarMarker.global_position
	$Ysort/Player.connect("shoot", Callable(self, "_on_player_shoot"))



func _on_player_shoot(dir: Vector2, origin: Vector2) -> void:
	if Globals.player_ammo > 0:
		var bullet = bullet_scene.instantiate()
		bullet.global_position = origin
		if "vel" in bullet:
			bullet.vel = dir * Globals.bullet_speed
		add_child(bullet)
		Globals.player_ammo -= 1
