extends Area2D

var drink_layers: Array[String] = ["", "", ""]   # holds ingredient names or ""
var ship_in_area : Node2D = null
@onready var ui = get_node_or_null("../UI")
signal drink_served(drink)
var _recipe_signatures: Dictionary = {}
var _queued_serve := false
@export var serve_delay := 0.25 
var _serve_cooldown_timer : Timer

var ingredient_colors := {
	"wine":    Color(1.0, 0.0, 0.0, 1.0),
	"baileys":     Color(0.81, 0.19, 0.12, 1.0),
	"whiskey": Color(0.9, 0.7, 0.7, 1.0),
	"vodka":   Color(0.0, 0.0, 1.0, 1.0),
	"plum":   Color(0.67, 0.0, 0.52, 1.0),
	"tonic":   Color(0.7, 0.7, 1.0, 1.0),
}

const RECIPES := {
	"Plum Wine":            {"wine": 2, "plum": 1},
	"Cosmopolitan":         {"vodka": 1, "plum": 1, "tonic": 1},
	"Magical & Milky (M&M)": {"baileys": 2, "whiskey": 1},
	"Plum Mocktail":        {"tonic": 2, "plum": 1},
}

const EMPTY_LAYER_COLOR := Color(1,1,1,1)

func _ready():
	_build_recipe_signatures()
	_serve_cooldown_timer = Timer.new()
	_serve_cooldown_timer.one_shot = true
	_serve_cooldown_timer.wait_time = serve_delay
	add_child(_serve_cooldown_timer)
	_serve_cooldown_timer.timeout.connect(_on_serve_cooldown_finished)

func _can_serve() -> bool:
	return _is_full() and _serve_cooldown_timer.is_stopped()

func _build_recipe_signatures():
	_recipe_signatures.clear()
	for name in RECIPES.keys():
		_recipe_signatures[_make_signature(RECIPES[name])] = name

func _normalize_ingredient(s: String) -> String:
	return s.strip_edges().to_lower()

func _make_signature(counts: Dictionary) -> String:
	var parts: Array[String] = []
	for ing in counts.keys():
		parts.append("%s:%d" % [_normalize_ingredient(ing), int(counts[ing])])
	parts.sort()
	return "|".join(parts)

func _count_layers(layers: Array) -> Dictionary:
	var counts := {}
	for raw in layers:
		if raw == null or raw == "" : continue
		var ing = raw.strip_edges()
		if ing == "": continue
		counts[ing] = counts.get(ing, 0) + 1
	return counts

func _process(_delta: float) -> void:
	if ship_in_area == null or not is_instance_valid(ship_in_area):
		return

	# Only react on key press
	if Input.is_action_just_pressed("land"):
		if not _is_body_still_overlapping(ship_in_area):
			return

		if _can_serve():
			_serve()
		else:
			if not _is_full():
				if "drink_held" in ship_in_area:
					var held = ship_in_area.get("drink_held")
					if held is String and held != "none":
						_pour(held)
			else:
				# full but cooldown still running
				_queued_serve = true

	# If player pressed while cooling down, serve once timer ends
	if _queued_serve and _can_serve():
		_queued_serve = false
		_serve()

	if Input.is_action_just_released("land") and ui:
		ui.landing_bar_visable(false)
		ui.landing_bar_reset()

func _is_full() -> bool:
	return drink_layers.find("") == -1

func _update_prompt():
	if ship_in_area and ship_in_area.has_method("change_controll_label"):
		if _is_full():
			if not _serve_cooldown_timer.is_stopped():
				ship_in_area.change_controll_label("...preparing...")
			else:
				ship_in_area.change_controll_label("Press E to serve")
		else:
			ship_in_area.change_controll_label("Press E to pour")

func _pour(held_drink: String) -> void:
	var idx := drink_layers.find("")
	if idx == -1:
		# Already full, nothing to pour.
		_update_prompt()
		return

	drink_layers[idx] = held_drink
	print("Layers now: ", drink_layers)
	$"../Ysort2/Player".change_holdable_visible(false)
	$"../Ysort2/Player".drink_held = "none"
	_update_visual_mix(idx)

	# If we just filled the last slot, start cooldown
	if _is_full():
		_serve_cooldown_timer.start()

	_update_prompt()

func _serve() -> void:
	var counts = _count_layers(drink_layers)
	var sig = _make_signature(counts)

	if _recipe_signatures.has(sig):
		var drink_name = _recipe_signatures[sig]
		drink_served.emit(drink_name)
	else:
		drink_served.emit("Unknown mixture")
		print("Unknown mixture:", drink_layers, "counts:", counts)
		if ui:
			#var suggestion = _closest_recipe(counts)
			#if suggestion != "":
				#ui.change_info("Unknown. Closest: " + suggestion)
			#else:
				#ui.change_info("Unknown drink.")
			pass

	for i in range(drink_layers.size()):
		drink_layers[i] = ""
	_reset_all_layers()
	_update_prompt()


func _update_visual_mix(_new_index: int) -> void:
	var filled_count := 0
	for ing in drink_layers:
		if ing != "":
			filled_count += 1

	if filled_count == 0:
		_reset_all_layers()
		return

	if filled_count == 1:
		for i in range(drink_layers.size()):
			var node := _get_layer_node(i)
			if node == null:
				continue
			if drink_layers[i] != "":
				node.modulate = ingredient_colors.get(drink_layers[i], EMPTY_LAYER_COLOR)
			else:
				node.modulate = EMPTY_LAYER_COLOR
	else:
		var mix := _compute_mix_color()
		_apply_mix_color(mix, true, true)

func _compute_mix_color() -> Color:
	var total_r := 0.0
	var total_g := 0.0
	var total_b := 0.0
	var total_a := 0.0
	var count := 0

	for ing in drink_layers:
		if ing == "":
			continue
		var c = ingredient_colors.get(ing, EMPTY_LAYER_COLOR)
		total_r += c.r
		total_g += c.g
		total_b += c.b
		total_a += c.a
		count += 1

	if count == 0:
		return EMPTY_LAYER_COLOR

	return Color(total_r / count, total_g / count, total_b / count, total_a / count)

func _apply_mix_color(mix: Color, filled_only: bool, tween: bool) -> void:
	for i in range(drink_layers.size()):
		var node := _get_layer_node(i)
		if node == null:
			continue
		var filled := drink_layers[i] != ""
		if filled_only and not filled:
			node.modulate = EMPTY_LAYER_COLOR
			continue

		var shade_factor := 1.0 - (i * 0.08)
		var layer_color := Color(
			clamp(mix.r * shade_factor, 0.0, 1.0),
			clamp(mix.g * shade_factor, 0.0, 1.0),
			clamp(mix.b * shade_factor, 0.0, 1.0),
			mix.a
		)

		if tween:
			var tw := create_tween()
			tw.tween_property(node, "modulate", layer_color, 0.25)
		else:
			node.modulate = layer_color

func _reset_all_layers():
	for i in range(drink_layers.size()):
		var node := _get_layer_node(i)
		if node:
			node.modulate = EMPTY_LAYER_COLOR

func _get_layer_node(i: int) -> Node:
	return get_node_or_null("DrinkLayers/DrinkLayer%d" % (i + 1))



func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		ship_in_area = body
		_update_prompt()

func _on_body_exited(body: Node2D) -> void:
	if body == ship_in_area:
		if body.has_method("change_controll_label"):
			body.change_controll_label("")
		ship_in_area = null

func _is_body_still_overlapping(body: Node2D) -> bool:
	if not monitoring:
		return true
	for b in get_overlapping_bodies():
		if b == body:
			return true
	return false

func _on_serve_cooldown_finished() -> void:
	# Timer finished – refresh the prompt if player still nearby
	if ship_in_area and is_instance_valid(ship_in_area):
		_update_prompt()

	# If player pressed E during cooldown, auto-serve now (if still full)
	if _queued_serve and _is_full():
		_queued_serve = false
		_serve()
	else:
		# Clear queued flag if glass is no longer full (edge case)
		if not _is_full():
			_queued_serve = false
