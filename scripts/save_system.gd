extends Node

const SAVE_PATH := "user://save.cfg"
const BACKUP_PATH := "user://save.cfg.bak"

var _cfg := ConfigFile.new()

func _ready() -> void:
	_load()

func _load() -> void:
	var err := _cfg.load(SAVE_PATH)
	if err != OK:
		# Try backup
		var berr := _cfg.load(BACKUP_PATH)
		if berr != OK:
			_cfg = ConfigFile.new()

func _save() -> void:
	# Rotate backup first
	if FileAccess.file_exists(SAVE_PATH):
		var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
		if f != null:
			var data := f.get_buffer(f.get_length())
			f.close()
			var b := FileAccess.open(BACKUP_PATH, FileAccess.WRITE)
			if b != null:
				b.store_buffer(data)
				b.close()
	_cfg.save(SAVE_PATH)

func mark_scene_complete(scene_id: String, hints_used: int) -> void:
	_cfg.set_value("scenes", scene_id + "_complete", true)
	_cfg.set_value("scenes", scene_id + "_hints", hints_used)
	_save()

func is_scene_complete(scene_id: String) -> bool:
	return _cfg.get_value("scenes", scene_id + "_complete", false)

func get_hints_used(scene_id: String) -> int:
	return _cfg.get_value("scenes", scene_id + "_hints", 0)

func reset() -> void:
	_cfg = ConfigFile.new()
	_save()
