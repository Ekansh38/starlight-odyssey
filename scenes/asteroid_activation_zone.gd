extends Area2D

var asteroid: PackedScene = load("res://scenes/asteroid_big.tscn")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Ship"):
		var asteroid_big = asteroid.instantiate()
		var spawn_pos = $"../AsteroidPos".global_position
		asteroid_big.global_position = spawn_pos

		var ship: Node2D = $"../Ship"
		if ship:
			var dir_to_ship: Vector2 = (ship.global_position - spawn_pos).normalized()
			asteroid_big.dir = dir_to_ship

		add_child(asteroid_big)

func _process(delta: float) -> void:
	if Globals.player_energy <= 10:
		Globals.player_energy = 100
	if Globals.ship_damage <= 10:
		Globals.ship_damage = 100
