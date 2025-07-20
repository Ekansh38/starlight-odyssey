extends NPC


func _ready() -> void:
	timeline = load("res://Timelines/Mayannaise.dch")
	timeline_name = "mayannaise"
	ui = get_node(ui_path)
	Dialogic.signal_event.connect(DialogicSignal)
	
	
