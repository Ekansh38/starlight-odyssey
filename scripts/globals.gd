extends Node

signal update_stats()

var player_ammo = 20:
	get:
		return player_ammo
	set(value):
		player_ammo = value
		update_stats.emit()

var energy_per_food = 35

var food_amount: int = 0:
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
		

var max_energy: float = 100.0

var ship_damage: float = 100.0:
	get:
		return ship_damage
	set(value):
		ship_damage = value
		update_stats.emit()
