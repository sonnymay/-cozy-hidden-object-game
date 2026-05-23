extends Node

# Loads a scene definition JSON and populates the gameplay scene tree.
# Expected JSON shape — see data/scene_01.json.

static func load_scene_data(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("Scene data not found: %s" % path)
		return {}
	var f := FileAccess.open(path, FileAccess.READ)
	var text := f.get_as_text()
	f.close()
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Scene data JSON invalid: %s" % path)
		return {}
	return parsed

static func populate(
	hidden_objects_root: Node,
	scene_data: Dictionary,
	clickable_script: Script
) -> Array:
	var created: Array = []
	var objects: Array = scene_data.get("hidden_objects", [])
	for entry in objects:
		var area := Area2D.new()
		area.set_script(clickable_script)
		area.object_id = entry.get("id", "")
		area.display_name = entry.get("display_name", entry.get("id", ""))
		var pos: Array = entry.get("position", [0, 0])
		area.position = Vector2(pos[0], pos[1])

		var poly := CollisionPolygon2D.new()
		var pts: Array = entry.get("polygon", [[-32, -32], [32, -32], [32, 32], [-32, 32]])
		var packed := PackedVector2Array()
		for p in pts:
			packed.append(Vector2(p[0], p[1]))
		poly.polygon = packed
		area.add_child(poly)

		# Sprite (optional — if file missing, render a colored rect)
		var sprite_path: String = entry.get("sprite", "")
		if sprite_path != "" and ResourceLoader.exists(sprite_path):
			var sprite := Sprite2D.new()
			sprite.texture = load(sprite_path)
			area.add_child(sprite)
		else:
			var rect := ColorRect.new()
			rect.color = Color(0.9, 0.6, 0.5, 0.9)
			rect.size = Vector2(64, 64)
			rect.position = Vector2(-32, -32)
			area.add_child(rect)

		hidden_objects_root.add_child(area)
		created.append(area)
	return created
