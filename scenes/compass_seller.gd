extends NPC

func _ready() -> void:
	if Globals.has_cosmic_compass:
		can_interact = false
	ui = get_node(ui_path)
	Dialogic.signal_event.connect(DialogicSignal)

	ui = get_node_or_null(ui_path)


func _process(delta: float) -> void:
	
	if player_in_area:
		if Input.is_action_just_pressed("land"):
			$CompassShop.transin()
				

func change_pickup_indicator(message):
	if ui: ui.change_pickup_indicator(message)

func change_info(message):

	if ui: ui.change_info(message)
