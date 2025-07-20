extends Node2D
class_name QueueLineManager

@export var line_positions_path: NodePath = ^"LinePositions"
@export var npc_scenes: Array[PackedScene]
@export var max_queue_size: int = 5
@export var spawn_interval: float = 1.0
@export var auto_spawn: bool = true

var _markers: Array[Marker2D] = []          # ordered back -> front
var _slots: Array[NPC] = []                 # same size as _markers (null = empty)
var _spawn_timer: float = 0.0

func _ready() -> void:
	randomize()
	_collect_markers()
	_slots.resize(_markers.size())
	for i in range(_slots.size()):
		_slots[i] = null
	if auto_spawn:
		_spawn_timer = spawn_interval

func _process(delta: float) -> void:
	if auto_spawn:
		_spawn_timer -= delta
		if _spawn_timer <= 0.0:
			_try_spawn()
			_spawn_timer = spawn_interval

# --------------------------------------------------
# Marker gathering & ordering
# --------------------------------------------------
func _collect_markers() -> void:
	_markers.clear()
	var parent = get_node_or_null(line_positions_path)
	if not parent:
		push_error("QueueLineManager: LinePositions not found: %s" % line_positions_path)
		return
	var temp: Array[Marker2D] = []
	for c in parent.get_children():
		if c is Marker2D:
			temp.append(c)
	# Sort by extracted numeric suffix
	temp.sort_custom(func(a, b):
		return _extract_index(a.name) < _extract_index(b.name)
	)
	_markers = temp
	max_queue_size = _markers.size()

func _extract_index(name: String) -> int:
	var digits := ""
	for i in name.length():
		var ch := name[i]
		if ch >= "0" and ch <= "9":
			digits += ch
	return int(digits) if digits != "" else 0

# --------------------------------------------------
# Spawning
# --------------------------------------------------
func _try_spawn() -> void:
	if npc_scenes.is_empty():
		return
	if _slots.is_empty():
		return
	# Only spawn if BACK slot free (index 0)
	if _slots[0] != null:
		return
	var scene: PackedScene = npc_scenes.pick_random()
	var npc: NPC = scene.instantiate()
	npc.global_position = global_position
	add_child(npc)
	_slots[0] = npc
	if not npc.move_finished.is_connected(_on_npc_move_finished):
		npc.move_finished.connect(_on_npc_move_finished)
	_move_npc_to_slot(npc, 0)
	_compress_queue()

# --------------------------------------------------
# Queue Compression
# --------------------------------------------------
func _compress_queue() -> void:
	var changed := true
	while changed:
		changed = false
		for i in range(_slots.size() - 2, -1, -1): # iterate from second-to-front backwards
			var npc := _slots[i]
			if npc == null:
				continue
			if npc.moving:
				continue
			if _slots[i + 1] == null:
				_slots[i + 1] = npc
				_slots[i] = null
				_move_npc_to_slot(npc, i + 1)
				changed = true

func _move_npc_to_slot(npc: NPC, slot_index: int) -> void:
	if slot_index < 0 or slot_index >= _markers.size():
		return
	npc.move_to(_markers[slot_index].global_position)

# --------------------------------------------------
# Serving front
# --------------------------------------------------
func serve_front() -> void:
	if _markers.is_empty():
		return
	var front_index := _markers.size() - 1
	var npc := _slots[front_index]
	if npc == null:
		return
	_slots[front_index] = null
	if is_instance_valid(npc):
		npc.queue_free()
	_compress_queue()

# --------------------------------------------------
# Signals
# --------------------------------------------------
func _on_npc_move_finished(npc: NPC) -> void:
	_compress_queue()

# --------------------------------------------------
# Debug
# --------------------------------------------------
