extends Node

signal object_found(object_id: String)
signal scene_complete(scene_id: String, hints_used: int)
signal hint_changed(remaining: int, cooldown_left: float)

const HINTS_PER_SCENE := 3

var current_scene_id: String = ""
var found_ids: Array[String] = []
var total_objects: int = 0
var hints_remaining: int = HINTS_PER_SCENE
var hints_used: int = 0

func start_scene(scene_id: String, total: int) -> void:
	current_scene_id = scene_id
	found_ids.clear()
	total_objects = total
	hints_remaining = HINTS_PER_SCENE
	hints_used = 0

func register_found(object_id: String) -> void:
	if object_id in found_ids:
		return
	found_ids.append(object_id)
	object_found.emit(object_id)
	if found_ids.size() >= total_objects:
		scene_complete.emit(current_scene_id, hints_used)
		SaveSystem.mark_scene_complete(current_scene_id, hints_used)

func consume_hint() -> bool:
	if hints_remaining <= 0:
		return false
	hints_remaining -= 1
	hints_used += 1
	return true
