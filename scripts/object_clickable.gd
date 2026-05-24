extends Area2D

signal found

@export var object_id: String = ""
@export var display_name: String = ""
@export var in_reveal: String = ""

var _is_found := false

func _ready() -> void:
	input_pickable = true
	input_event.connect(_on_input_event)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if _is_found:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_mark_found()

func _mark_found() -> void:
	_is_found = true
	found.emit()
	GameManager.register_found(object_id)
	# Visual feedback: fade sprite child if present
	for child in get_children():
		if child is CanvasItem:
			var tween := create_tween()
			tween.tween_property(child, "modulate:a", 0.0, 0.25)
	# Disable further input
	set_deferred("input_pickable", false)
