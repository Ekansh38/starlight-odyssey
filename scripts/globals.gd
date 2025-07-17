extends Node

signal update_stats()

signal update_compass()

var bullet_speed = 3000
var _game_over_triggered := false

var shop_items = {
	0: {
		"Name": "Basic Repair",
		"Des": "Restores 10 Damage",
		"Cost": 5


	},
	1: {	
		"Name": "Premium Repair",
		"Des": "Restores 25 Damage",
		"Cost": 12


	},
	2: {
		"Name": "Ship Overhaul",
		"Des": "Restores 50 Damage",
		"Cost": 20
	},
}

var money = 200:
	get:
		return money
	set(value):
		money = value
		update_stats.emit()

var has_cosmic_compass = false:
	get:
		return has_cosmic_compass
	set(value):
		has_cosmic_compass = value
		update_compass.emit()

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
