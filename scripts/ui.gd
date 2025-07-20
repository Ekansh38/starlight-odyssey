extends CanvasLayer

@onready var label = $FPSLabel
var _acc := 0.0
var _frames := 0



@onready var pickup_label: Label = $PickupIndicator

@export var appear_time    : float = 0.18    # slide + fade in duration
@export var visible_time   : float = 1.0     # how long it remains fully visible
@export var disappear_time : float = 0.18    # fade out duration
@export var y_offset       : float = 12.0    # how far below it starts for the slide

var _show_tween : Tween
var _hide_tween : Tween
var _lifetime_timer : Timer
var _base_position : Vector2
var _current_message_id: int = 0  # increments to invalidate older hides



func _process(delta):
	_acc += delta
	_frames += 1
	if _acc >= 0.5:
		var fps = _frames / _acc
		var ft_ms = (1000.0 / fps)
		label.text = "%d FPS  (%.2f ms)" % [fps, ft_ms]
		_acc = 0
		_frames = 0

func _ready() -> void:
	hitman_photo_visible(false)

	Globals.connect("update_stats", update_stats)
	$HitmanTimerLabel.text = ""
	update_stats()
	if not pickup_label:
		push_error("PickupIndicator label not found.")
		return
	_base_position = pickup_label.position
	pickup_label.visible = false
	pickup_label.modulate.a = 0.0
	# build a reusable timer
	_lifetime_timer = Timer.new()
	_lifetime_timer.one_shot = true
	add_child(_lifetime_timer)
	_lifetime_timer.connect("timeout", Callable(self, "_on_visible_timeout"))

	

func update_stats():
	$VBoxContainer/Energy.value = Globals.player_energy
	$VBoxContainer2/ShipDamage.value = Globals.ship_damage
	$HBoxContainer/Amount.text = str(Globals.food_amount) + "/" + str(Globals.max_food)
	$Money/Money.text = str(Globals.money)
	$Ammo/Ammo.text = str(Globals.player_ammo)

func change_info(message):
	print("CALLED")

	$InfoLabel.text = message
	if message == "ASSASINATION SUCSESSFUL!":
		await get_tree().create_timer(1.5).timeout
		$InfoLabel.text = ""
	elif message == "Launch into space to use.":
		await get_tree().create_timer(4).timeout
		$InfoLabel.text = ""


func change_minor_info(message):
	$InfoLabel2.text = message
	
func modulate_screen(mod_color):
	$ColorRect.color = mod_color
	
	

func can_bar_visable(the_bool: bool):
	
	$SelfCanniblizeBar.visible = the_bool
	$LandingBar.visible = false
	$ZoomOutBar.visible = false
		
func can_bar_update():
	$SelfCanniblizeBar.value += 1
	
func can_bar_value():
	return $SelfCanniblizeBar.value
	
func can_bar_reset():
	$SelfCanniblizeBar.value = 0
	
	

func landing_bar_visable(the_bool: bool):
	$LandingBar.visible = the_bool
	$SelfCanniblizeBar.visible = false
	$ZoomOutBar.visible = false

	
func landing_bar_update():
	$LandingBar.value += 2
	
func landing_bar_value():
	return $LandingBar.value
	
func landing_bar_reset():
	$LandingBar.value = 0
	
func speed_lines_visablity(value: bool):
	$SpeedLines.visible = value
	
func minor_info_shown():
	if $InfoLabel2.text != "":
		return true
	else:
		return false
		
func zoom_bar_visable(the_bool: bool):
	$ZoomOutBar.visible = the_bool
	$LandingBar.visible = false
	$SelfCanniblizeBar.visible = false

	
func zoom_bar_update():
	$ZoomOutBar.value += 1
	
func zoom_bar_value():
	return $ZoomOutBar.value
	
func zoom_bar_reset():
	$ZoomOutBar.value = 0

func change_pickup_indicator(message: String) -> void:
	if message == "":
		_clear_immediately()
		return

	_current_message_id += 1  
	var msg_id = _current_message_id

	_kill_tween(_show_tween)
	_kill_tween(_hide_tween)
	_lifetime_timer.stop()

	pickup_label.text = message
	pickup_label.visible = true

	if pickup_label.modulate.a < 0.01:
		pickup_label.position = _base_position + Vector2(0, y_offset)

	_show_tween = create_tween()
	_show_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_show_tween.parallel().tween_property(
		pickup_label, "position", _base_position, appear_time
	)
	_show_tween.parallel().tween_property(
		pickup_label, "modulate:a", 1.0, appear_time
	)

	_show_tween.tween_callback(Callable(self, "_start_visible_timer").bind(msg_id))

func _start_visible_timer(msg_id: int) -> void:
	if msg_id != _current_message_id:
		return
	_lifetime_timer.start(visible_time)

func _on_visible_timeout() -> void:
	if _lifetime_timer.time_left > 0:
		return
	var msg_id = _current_message_id
	_start_hide_tween(msg_id)

func _start_hide_tween(msg_id: int) -> void:
	_kill_tween(_hide_tween)
	_hide_tween = create_tween()
	_hide_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_hide_tween.tween_property(pickup_label, "modulate:a", 0.0, disappear_time)
	_hide_tween.tween_callback(Callable(self, "_finish_hide").bind(msg_id))

func _finish_hide(msg_id: int) -> void:
	# If a new message appeared while fading out, do not hide.
	if msg_id != _current_message_id:
		return
	pickup_label.visible = false
	pickup_label.position = _base_position  # reset position (optional)

func _clear_immediately() -> void:
	_kill_tween(_show_tween)
	_kill_tween(_hide_tween)
	_lifetime_timer.stop()
	pickup_label.modulate.a = 0.0
	pickup_label.visible = false
	pickup_label.position = _base_position

func _kill_tween(tw: Tween) -> void:
	if tw and tw.is_valid():
		tw.kill()
		
func hitman_photo_visible(the_bool):
	$HitmanPhotoFrame.visible = the_bool
	$HitmanPhoto.visible = the_bool
	$HitmanLabel.visible = the_bool
	
const HITMAN_DURATION := 60          # total seconds (1 minute)
const WARNING_THRESHOLD := 10        # when to turn red / shake

@onready var hitman_timer: Timer = $HitmanTimer
@onready var hitman_label: Label = $HitmanTimerLabel

var hitman_seconds_left: int = 0
var hitman_active: bool = false

func start_hitman_timer():
	if hitman_active:
		return                      # already running
	hitman_seconds_left = HITMAN_DURATION
	hitman_active = true
	_update_hitman_label()

	# Configure the internal 1-second ticking timer
	hitman_timer.wait_time = 1.0
	hitman_timer.one_shot = false
	if not hitman_timer.timeout.is_connected(_on_hitman_tick):
		hitman_timer.timeout.connect(_on_hitman_tick)
	hitman_timer.start()

func cancel_hitman_timer():
	if not hitman_active:
		return
	hitman_active = false
	hitman_timer.stop()
	hitman_label.text = ""  # or keep the last shown time

func _on_hitman_tick():
	if not hitman_active:
		return

	hitman_seconds_left -= 1
	if hitman_seconds_left <= 0:
		hitman_seconds_left = 0
		_update_hitman_label()
		hitman_timer.stop()
		hitman_active = false
		_on_hitman_timer_finished()
	else:
		_update_hitman_label()

func _update_hitman_label():
	var m := hitman_seconds_left / 60
	var s := hitman_seconds_left % 60
	hitman_label.text = "%02d:%02d" % [m, s]

	if hitman_seconds_left <= WARNING_THRESHOLD and hitman_seconds_left > 0:
		hitman_label.modulate = Color(1, 0.2, 0.2)
		_shake_label()
	else:
		hitman_label.modulate = Color(1, 1, 1)

func _shake_label():
	# Simple small horizontal shake
	var base_pos := hitman_label.position
	var tw := hitman_label.create_tween()
	tw.tween_property(hitman_label, "position:x", base_pos.x + 4, 0.05).set_trans(Tween.TRANS_SINE)
	tw.tween_property(hitman_label, "position:x", base_pos.x - 4, 0.05).set_trans(Tween.TRANS_SINE)
	tw.tween_property(hitman_label, "position:x", base_pos.x,       0.05).set_trans(Tween.TRANS_SINE)

func _on_hitman_timer_finished():
	if Globals.is_in_hitman_game:
		change_info("ASSASINATION FAILED")
		$HitmanTimerLabel.text = ""
		hitman_photo_visible(false)
		await get_tree().create_timer(2).timeout
		change_info("")
