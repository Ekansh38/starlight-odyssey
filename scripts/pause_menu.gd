extends CanvasLayer

var is_paused := false

@export var design_resolution: Vector2i = Vector2i(1280, 720)
@export var aspect_mode: int = Window.CONTENT_SCALE_ASPECT_KEEP

var performance = false

func _ready() -> void:
	layer = 100
	hide_ui()
	if OS.has_feature("web"):
		_apply_viewport_mode()
		performance = true
	else:
		_normal_mode()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		toggle_pause()

func toggle_pause():
	is_paused = !is_paused
	get_tree().paused = is_paused
	if is_paused:
		show_ui()
	else:
		hide_ui()

func hide_ui():
	$ColorRect.visible = false
	$VBoxContainer.visible = false

func show_ui():
	$ColorRect.visible = true
	$VBoxContainer.visible = true

func _on_continue_pressed() -> void:
	if is_paused:
		toggle_pause()

func _apply_viewport_mode():
	var root := get_tree().root
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	root.content_scale_aspect = aspect_mode
	root.content_scale_size = design_resolution
	root.size = DisplayServer.window_get_size()
	print("Viewport stretch applied at", design_resolution)

func _normal_mode():
	var root := get_tree().root
	root.content_scale_mode   = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP  
	root.content_scale_factor = 1.0   


func _on_performance_mode_pressed() -> void:
	if performance:
		_normal_mode()
		performance = false
	else:
		_apply_viewport_mode()
		performance = true
