extends Node

signal update_stats
signal update_compass

const GAME_OVER_SCENE := "res://scenes/game_over.tscn"

# -------------------------------------------------
# DATA TABLES
# -------------------------------------------------

var thruster_power: float = 2.5
var boost_energy_use: float = 1.3

var is_in_hitman_game: bool = false

var repairs = {
	0: {
		"Name": "Basic Repair",
		"Des": "Restores 10 Damage",
		"Cost": 15,
		"Icon": preload("res://assets/Basic-Repair.png")

	},
	1: {	
		"Name": "Premium Repair",
		"Des": "Restores 25 Damage",
		"Cost": 35,
		"Icon": preload("res://assets/Premium-Repair.png")

	},
	2: {
		"Name": "Ship Overhaul",
		"Des": "Restores 50 Damage",
		"Cost": 65,
		"Icon": preload("res://assets/Ship-Overhaul.png")

	},
	3: {
		"Name": "Better Thrusters",
		"Des": "More powerful thrusters",
		"Cost": 60,
		"Icon": preload("res://assets/Space stuff extras 2/Icons/Better thrusters.png")
	}
}

var gun_items = {
	0: {
		"Name": "Pistol",
		"Des": "Shoots people",
		"Cost": 20,
		"Icon": preload("res://assets/Space stuff extras/Icons/pixil-frame-0-524.png")
	},
	1: {
		"Name": "Ammo Mag",
		"Des": "+10 Ammo",
		"Cost": 15,
		"Icon": preload("res://assets/Space stuff extras/Icons/pixil-frame-0-524.png")
	},

}

var compass_items = {
		0: {
		"Name": "Cosmic Compass",
		"Des": "Points Toward Earth",
		"Cost": 90,
		"Icon": preload("res://assets/pixil-frame-0-519.png")

	},

}

var food_items = {
	0: {
		"Name": "Snack",
		"Des": "+1 Food",
		"Cost": 10,
		"Icon": preload("res://assets/Space stuff extras/Icons/pixil-frame-0-522.png")

	},
	1: {	
		"Name": "Meal",
		"Des": "+3 Food",
		"Cost": 24,
		"Icon": preload("res://assets/Space stuff extras/Icons/pixil-frame-0-523.png")

	},
	2: {
		"Name": "Bundle",
		"Des": "+2 Max Food",
		"Cost": 50,
		"Icon": preload("res://assets/Space stuff extras 2/Icons/Bundle of food.png")

	},
}
# -------------------------------------------------
# STATE (backing variables)
# -------------------------------------------------

var did_play_bar_game = false
var bar_game_score = 0

var bullet_speed := 3000
var _game_over_triggered := false
var did_player_exit_bar := false

var _money := 100
var _has_cosmic_compass := false

var last_ship_position: Vector2 = Vector2.ZERO
var has_saved_ship_pos := false

var _player_ammo := 15
var _energy_per_food := 35

var _food_amount := 3
var _max_food := 3

var _player_energy := 100.0
var _max_energy := 100.0

var _ship_damage := 100.0   # hull / integrity (0..100)

# -------------------------------------------------
# PROPERTIES (public accessors)
# -------------------------------------------------
var money:
	get: return _money
	set(value):
		_money = max(0, value)
		update_stats.emit()

var has_cosmic_compass:
	get: return _has_cosmic_compass
	set(value):
		_has_cosmic_compass = value
		update_compass.emit()

var player_ammo:
	get: return _player_ammo
	set(value):
		_player_ammo = max(0, value)
		update_stats.emit()

var energy_per_food:
	get: return _energy_per_food
	set(value):
		_energy_per_food = max(1, value)

var food_amount:
	get: return _food_amount
	set(value):
		_food_amount = clamp(value, 0, _max_food)
		update_stats.emit()

var max_food:
	get: return _max_food
	set(value):
		_max_food = max(1, value)
		_food_amount = min(_food_amount, _max_food)
		update_stats.emit()

var max_energy:
	get: return _max_energy
	set(value):
		_max_energy = max(1.0, value)
		_player_energy = clamp(_player_energy, 0.0, _max_energy)
		update_stats.emit()
		_check_game_over()

var player_energy:
	get: return _player_energy
	set(value):
		_player_energy = clamp(value, 0.0, _max_energy)
		update_stats.emit()
		_check_game_over()

var ship_damage:
	get: return _ship_damage
	set(value):
		_ship_damage = clamp(value, 0.0, 100.0)
		update_stats.emit()
		_check_game_over()


var player_has_gun: bool = false

# -------------------------------------------------
# GAME OVER MANAGEMENT
# -------------------------------------------------

func _check_game_over() -> void:
	if _game_over_triggered:
		return
	if _player_energy <= 0.0 or _ship_damage <= 0.0:
		_trigger_game_over()

func _trigger_game_over() -> void:
	if _game_over_triggered:
		return
	_game_over_triggered = true
	call_deferred("_do_game_over")

func _do_game_over() -> void:
	var tree := get_tree()
	if tree:
		tree.change_scene_to_file(GAME_OVER_SCENE)

# -------------------------------------------------
# RESET
# -------------------------------------------------
func reset() -> void:
	thruster_power = 2.5
	boost_energy_use = 1.3
	_game_over_triggered = false

	_money = 100
	_has_cosmic_compass = false
	_player_ammo = 15
	_energy_per_food = 35

	_food_amount = 3
	_max_food = 3

	_max_energy = 100.0
	_player_energy = 100.0

	_ship_damage = 100.0

	last_ship_position = Vector2.ZERO
	has_saved_ship_pos = false
	did_player_exit_bar = false

	update_stats.emit()
	update_compass.emit()
