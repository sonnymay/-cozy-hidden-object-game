extends Node

const COOLDOWN_SEC := 60.0
const PULSE_DURATION := 2.0

signal pulse_at(position: Vector2)
signal cooldown_tick(remaining: float)

var _cooldown_left: float = 0.0
var _hidden_objects_node: Node = null

func bind(hidden_objects: Node) -> void:
	_hidden_objects_node = hidden_objects

func _process(delta: float) -> void:
	if _cooldown_left > 0.0:
		_cooldown_left = max(0.0, _cooldown_left - delta)
		cooldown_tick.emit(_cooldown_left)

func request_hint() -> bool:
	if _cooldown_left > 0.0:
		return false
	if _hidden_objects_node == null:
		return false
	var unfound: Array = []
	for child in _hidden_objects_node.get_children():
		if child is Area2D and child.input_pickable:
			unfound.append(child)
	if unfound.is_empty():
		return false
	if not GameManager.consume_hint():
		return false
	var target: Node2D = unfound[randi() % unfound.size()]
	pulse_at.emit(target.global_position)
	_cooldown_left = COOLDOWN_SEC
	return true
