extends Node

signal update_stats()

signal update_compass()

var bullet_speed = 3000
var _game_over_triggered := false

var repairs = {
	0: {
		"Name": "Basic Repair",
		"Des": "Restores 10 Damage",
		"Cost": 5,
		"Icon": preload("res://assets/Basic-Repair.png")


	},
	1: {	
		"Name": "Premium Repair",
		"Des": "Restores 25 Damage",
		"Cost": 12,
		"Icon": preload("res://assets/Premium-Repair.png")



	},
	2: {
		"Name": "Ship Overhaul",
		"Des": "Restores 50 Damage",
		"Cost": 20,
		"Icon": preload("res://assets/Ship-Overhaul.png")

	},
}



var food_items = {
	0: {
		"Name": "Snack",
		"Des": "+1 Food",
		"Cost": 5,
		"Icon": preload("res://assets/snack.png")


	},
	1: {	
		"Name": "Meal",
		"Des": "+3 Food",
		"Cost": 12,
		"Icon": preload("res://assets/meal.png")



	},
	2: {
		"Name": "Bundle",
		"Des": "+2 Max Food",
		"Cost": 25,
		"Icon": preload("res://assets/bundle.png")

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
		if value >= 100:
			ship_damage = 100
		else:
			ship_damage = value
		update_stats.emit()
		
		if not _game_over_triggered and ship_damage <= 0.0:
			_game_over_triggered = true
			get_tree().change_scene_to_file("res://scenes/game_over.tscn")
