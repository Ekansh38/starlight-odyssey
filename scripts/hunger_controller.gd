# HungerController.gd
extends Node
class_name HungerController

# Inputs
@export var eat_action         : String = "eat"
@export var cannibalize_action : String = "self-cannibalization"

# Durations
@export var cannibalize_duration : float = 5.0
@export var cannibalize_cooldown : float = 1.0

# Tuning
var food_per_ration  = Globals.energy_per_food

# State
var can_cannibalize := true

# Internal refs
var ui : Node 
var cam: Camera2D

func _ready() -> void:
	# find UI by group
	for n in get_tree().get_nodes_in_group("UI"):
		ui = n
		break
	if ui == null:
		push_error("HungerController: no node in group 'UI' found")

	# find Camera2D sibling if you want shake/tint
	cam = get_parent().get_node_or_null("Camera2D")

	set_process(true)

func _process(delta: float) -> void:
	# — EATING —
	if Input.is_action_just_pressed(eat_action):
		_eat()

	# — SELF-CANNIBALIZATION BAR —
	if Input.is_action_just_pressed(cannibalize_action) and Globals.max_energy >= 20:
		ui.can_bar_visable(true)
	if Input.is_action_pressed(cannibalize_action) and Globals.max_energy >= 20:
		ui.can_bar_update()
	if ui.can_bar_value() >= 100 and can_cannibalize:
		ui.can_bar_visable(false)
		ui.can_bar_reset()
		_start_cannibalize()
	if Input.is_action_just_released(cannibalize_action):
		ui.can_bar_reset()
		ui.can_bar_visable(false)

	# — LOW-ENERGY MINOR ALERT —
	if Globals.player_energy <= 20 and not ui.minor_info_shown:
		ui.change_minor_info("LOW ENERGY: 'G' to cannibalize or 'F' to eat")
	elif Globals.player_energy > 20 and ui.minor_info_shown:
		ui.change_minor_info("")

func _eat() -> void:
	if Globals.food_amount >= 1 and Globals.player_energy < Globals.max_energy:
		Globals.food_amount -= 1
		Globals.player_energy = min(Globals.player_energy + food_per_ration, Globals.max_energy)
		# $EatingSFX.play()
		ui.change_info("")   # clear any “No food” text
	else:
		# $OutOfFoodSFX.play()
		if Globals.food_amount <= 0:
			ui.change_info("No food.")
		else:
			ui.change_info("Energy is already max.")
		await get_tree().create_timer(0.5).timeout
		ui.change_info("")

func _start_cannibalize() -> void:
	if not can_cannibalize:
		return
	can_cannibalize = false
	# apply penalty & refill
	Globals.max_energy    = max(Globals.max_energy - 10, 10)
	Globals.player_energy = Globals.max_energy

	# $CrunchSFX.play()
	if cam:
		cam.start_shake(5)
		ui.modulate_screen(Color(1,0.2,0.2,0.2))

	ui.change_info("CANNIBALIZED.")
	await get_tree().create_timer(1.0).timeout
	ui.change_info("")
	ui.modulate_screen(Color(1,1,1,0))

	# cooldown before next
	await get_tree().create_timer(cannibalize_cooldown).timeout
	can_cannibalize = true
