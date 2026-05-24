extends Node

const COOLDOWN_SEC := 60.0

signal pulse_at(position: Vector2)
signal cooldown_tick(remaining: float)

var _cooldown_left: float = 0.0
var _hidden_objects_node: Node = null
var _reveals_open: Dictionary = {} # reveal_id -> bool
var _reveal_positions: Dictionary = {} # reveal_id -> Vector2

func bind(hidden_objects: Node) -> void:
	_hidden_objects_node = hidden_objects

func register_reveals(reveal_data: Array) -> void:
	for r in reveal_data:
		_reveals_open[r.id] = false
		_reveal_positions[r.id] = r.position

func mark_reveal_open(reveal_id: String) -> void:
	if reveal_id in _reveals_open:
		_reveals_open[reveal_id] = true

func _process(delta: float) -> void:
	if _cooldown_left > 0.0:
		_cooldown_left = max(0.0, _cooldown_left - delta)
		cooldown_tick.emit(_cooldown_left)

func request_hint() -> bool:
	if _cooldown_left > 0.0:
		return false
	if _hidden_objects_node == null:
		return false

	# Bucket unfound items: those already accessible vs those still inside closed reveals
	var accessible: Array = []
	var locked_by_reveal: Dictionary = {} # reveal_id -> Array[Area2D]
	for child in _hidden_objects_node.get_children():
		if not (child is Area2D):
			continue
		if not child.input_pickable:
			continue
		var rid := ""
		if "in_reveal" in child:
			rid = child.in_reveal
		if rid != "" and not _reveals_open.get(rid, false):
			locked_by_reveal.get_or_add(rid, []).append(child)
		else:
			accessible.append(child)

	# Prefer pointing at a closed reveal whose items are still missing
	for rid in locked_by_reveal.keys():
		if rid in _reveal_positions:
			if not GameManager.consume_hint():
				return false
			pulse_at.emit(_reveal_positions[rid])
			_cooldown_left = COOLDOWN_SEC
			return true

	if accessible.is_empty():
		return false
	if not GameManager.consume_hint():
		return false
	var target: Node2D = accessible[randi() % accessible.size()]
	pulse_at.emit(target.global_position)
	_cooldown_left = COOLDOWN_SEC
	return true
