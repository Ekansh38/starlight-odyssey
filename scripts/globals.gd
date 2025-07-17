extends Node

signal update_stats()

var bullet_speed = 3000
var _game_over_triggered := false


var last_ship_position: Vector2 = Vector2.ZERO
var has_saved_ship_pos: bool    = false

var player_ammo = 100:
	get:
		return player_ammo
	set(value):
		player_ammo = value
		update_stats.emit()

var energy_per_food = 35

var food_amount: int = 3:
	get:
		return food_amount
	set(value):
		food_amount = value
		update_stats.emit()
		
var max_food: int = 3:
	get:
		return max_food
	set(value):
		max_food = value
		update_stats.emit()
		

var player_energy: float = 100:
	get:
		return player_energy
	set(value):
		if value <= max_energy:
			player_energy = value
		else:
			player_energy = max_energy
			
		update_stats.emit()
		
		if not _game_over_triggered and player_energy <= 0.0:
			_game_over_triggered = true
			get_tree().change_scene_to_file("res://scenes/game_over.tscn")
		

var max_energy: float = 100.0

var ship_damage: float = 100.0:
	get:
		return ship_damage
	set(value):
		ship_damage = value
		update_stats.emit()
