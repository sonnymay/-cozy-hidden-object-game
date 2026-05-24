extends Node

# Loads scene JSON and instantiates hidden objects, interactive props, and reveals.
# See data/scene_01.json for the expected schema.

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
		area.in_reveal = entry.get("in_reveal", "")
		var pos: Array = entry.get("position", [0, 0])
		area.position = Vector2(pos[0], pos[1])

		var poly := CollisionPolygon2D.new()
		var pts: Array = entry.get("polygon", [[-64, -64], [64, -64], [64, 64], [-64, 64]])
		var packed := PackedVector2Array()
		for p in pts:
			packed.append(Vector2(p[0], p[1]))
		poly.polygon = packed
		area.add_child(poly)

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

		# Items hidden inside reveals start invisible + not clickable
		if area.in_reveal != "":
			area.modulate.a = 0.0
			area.input_pickable = false

		hidden_objects_root.add_child(area)
		created.append(area)
	return created

static func populate_props(props_root: Node, scene_data: Dictionary) -> Array:
	# Returns Array of Dictionary { id, area, sprite, reaction, position }
	var created: Array = []
	for entry in scene_data.get("props", []):
		var area := Area2D.new()
		area.name = "Prop_" + str(entry.get("id", ""))
		var pos: Array = entry.get("position", [0, 0])
		area.position = Vector2(pos[0], pos[1])

		var size_arr: Array = entry.get("size", [128, 128])
		var size := Vector2(size_arr[0], size_arr[1])

		var shape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = size
		shape.shape = rect
		area.add_child(shape)

		var sprite_path: String = entry.get("sprite", "")
		var sprite: Sprite2D = null
		if sprite_path != "" and ResourceLoader.exists(sprite_path):
			sprite = Sprite2D.new()
			sprite.texture = load(sprite_path)
			area.add_child(sprite)

		props_root.add_child(area)
		created.append({
			"id": entry.get("id", ""),
			"area": area,
			"sprite": sprite,
			"reaction": entry.get("reaction", "wobble"),
			"position": Vector2(pos[0], pos[1]),
		})
	return created

static func populate_reveals(reveals_root: Node, scene_data: Dictionary) -> Array:
	# Returns Array of Dictionary { id, area, sprite, type, sprite_open_path, position }
	var created: Array = []
	for entry in scene_data.get("reveals", []):
		var area := Area2D.new()
		area.name = "Reveal_" + str(entry.get("id", ""))
		var pos: Array = entry.get("position", [0, 0])
		area.position = Vector2(pos[0], pos[1])

		var size_arr: Array = entry.get("size", [128, 128])
		var size := Vector2(size_arr[0], size_arr[1])

		var shape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = size
		shape.shape = rect
		area.add_child(shape)

		var closed_path: String = entry.get("sprite_closed", "")
		var sprite: Sprite2D = null
		if closed_path != "" and ResourceLoader.exists(closed_path):
			sprite = Sprite2D.new()
			sprite.texture = load(closed_path)
			area.add_child(sprite)

		reveals_root.add_child(area)
		created.append({
			"id": entry.get("id", ""),
			"area": area,
			"sprite": sprite,
			"type": entry.get("type", "swing_doors"),
			"sprite_open_path": entry.get("sprite_open", ""),
			"position": Vector2(pos[0], pos[1]),
		})
	return created
