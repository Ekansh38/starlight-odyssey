extends NPC


func _ready() -> void:
	timeline = load("res://Timelines/Moko.dch")
	timeline_name = "moko"
	ui = get_node(ui_path)
	Dialogic.signal_event.connect(DialogicSignal)
	Dialogic.VAR.has_gun = Globals.player_has_gun


func _process(delta: float) -> void:
	
	if player_in_area:
		if Input.is_action_just_pressed("land"):
			if can_interact:
				Dialogic.VAR.has_gun = Globals.player_has_gun
				var layer = Dialogic.start(timeline_name)
				layer.register_character(timeline, $TextBoxMarker)
				player_in_area.change_controll_label("")
