extends Button

func _ready() -> void:
	print("[Button] ready! name =", name)
	pressed.connect(_on_pressed)
	gui_input.connect(_on_gui_input) # only fires if mouse_filter != Ignore

func _on_pressed() -> void:
	print("[Button] PRESSED")

func _on_gui_input(event: InputEvent) -> void:
	print("[Button] GUI INPUT:", event)
