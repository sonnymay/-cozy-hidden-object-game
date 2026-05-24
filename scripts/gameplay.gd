extends Node2D

@export var scene_data_path: String = "res://data/scene_01.json"
@export var parallax_strength: float = 30.0

@onready var parallax: ParallaxBackground = $Parallax
@onready var hidden_objects: Node2D = $HiddenObjects
@onready var props_root: Node2D = $Props
@onready var reveals_root: Node2D = $Reveals
@onready var particles: GPUParticles2D = $Particles/FoundSparkle
@onready var object_list: VBoxContainer = $HUD/Panel/ObjectList
@onready var hint_button: Button = $HUD/HintButton
@onready var hint_label: Label = $HUD/HintLabel
@onready var prop_counter: Label = $HUD/PropCounter
@onready var pulse: Node2D = $HUD/HintPulse
@onready var completion_panel: Panel = $HUD/CompletionPanel
@onready var completion_label: Label = $HUD/CompletionPanel/VBox/Label
@onready var chime: AudioStreamPlayer = $Chime
@onready var lantern_glow: PointLight2D = $Ambient/LanternGlow

const ClickableScript := preload("res://scripts/object_clickable.gd")
const SceneLoader := preload("res://scripts/scene_loader.gd")
const HintSystemScript := preload("res://scripts/hint_system.gd")

var _hint_system: Node
var _row_by_id: Dictionary = {}
var _props: Array = []   # from SceneLoader.populate_props
var _reveals: Array = [] # from SceneLoader.populate_reveals
var _reveal_by_id: Dictionary = {}
var _props_touched: Dictionary = {}
var _flicker_t: float = 0.0

func _ready() -> void:
	_hint_system = HintSystemScript.new()
	add_child(_hint_system)
	_hint_system.bind(hidden_objects)
	_hint_system.pulse_at.connect(_on_pulse_at)
	_hint_system.cooldown_tick.connect(_on_cooldown_tick)

	var data := SceneLoader.load_scene_data(scene_data_path)
	if data.is_empty():
		return

	# Layer 3: reveals first (so hidden-object spawn can mark in_reveal items invisible)
	_reveals = SceneLoader.populate_reveals(reveals_root, data)
	for r in _reveals:
		_reveal_by_id[r.id] = r
		r.area.input_event.connect(_on_reveal_input.bind(r))
	_hint_system.register_reveals(_reveals)

	# Layer 2: interactive props
	_props = SceneLoader.populate_props(props_root, data)
	for p in _props:
		p.area.input_event.connect(_on_prop_input.bind(p))

	# Hidden objects
	var areas: Array = SceneLoader.populate(hidden_objects, data, ClickableScript)
	GameManager.start_scene(data.get("scene_id", "scene_01"), areas.size())
	_build_object_list(areas)
	for area in areas:
		area.found.connect(_on_object_found.bind(area))

	hint_button.pressed.connect(_on_hint_pressed)
	GameManager.scene_complete.connect(_on_scene_complete)
	completion_panel.visible = false
	prop_counter.text = "Delights: 0/%d" % _props.size()
	_update_hint_label()

func _build_object_list(areas: Array) -> void:
	for child in object_list.get_children():
		child.queue_free()
	for area in areas:
		var lbl := Label.new()
		var prefix := ""
		if area.in_reveal != "":
			prefix = "? "
		lbl.text = prefix + area.display_name
		object_list.add_child(lbl)
		_row_by_id[area.object_id] = lbl

func _on_object_found(area: Area2D) -> void:
	var row: Label = _row_by_id.get(area.object_id, null)
	if row != null:
		row.modulate = Color(0.5, 0.5, 0.5, 0.7)
		row.text = "✓ " + area.display_name
	particles.global_position = area.global_position
	particles.restart()
	particles.emitting = true
	if chime.stream != null:
		chime.play()

func _on_hint_pressed() -> void:
	_hint_system.request_hint()
	_update_hint_label()

func _on_pulse_at(pos: Vector2) -> void:
	pulse.global_position = pos
	pulse.visible = true
	var tween := create_tween()
	tween.tween_property(pulse, "scale", Vector2(1.6, 1.6), 1.0)
	tween.parallel().tween_property(pulse, "modulate:a", 0.0, 2.0)
	tween.tween_callback(func() -> void:
		pulse.visible = false
		pulse.scale = Vector2.ONE
		pulse.modulate.a = 1.0)

func _on_cooldown_tick(_remaining: float) -> void:
	_update_hint_label()

func _update_hint_label() -> void:
	hint_label.text = "Hints: %d/%d" % [GameManager.hints_remaining, GameManager.HINTS_PER_SCENE]

func _on_continue_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_scene_complete(scene_id: String, hints_used: int) -> void:
	completion_label.text = "Scene complete!\nFound %d/%d\nHints used: %d\nDelights touched: %d/%d" % [
		GameManager.found_ids.size(), GameManager.total_objects, hints_used,
		_props_touched.size(), _props.size()
	]
	completion_panel.visible = true

# ============ Layer 2 props ============
func _on_prop_input(_viewport: Node, event: InputEvent, _shape_idx: int, prop: Dictionary) -> void:
	if not (event is InputEventMouseButton): return
	if not event.pressed: return
	if event.button_index != MOUSE_BUTTON_LEFT: return
	_props_touched[prop.id] = true
	prop_counter.text = "Delights: %d/%d" % [_props_touched.size(), _props.size()]
	_trigger_prop_reaction(prop)

func _trigger_prop_reaction(prop: Dictionary) -> void:
	var sp: Sprite2D = prop.sprite
	if sp == null: return
	var tween := create_tween()
	match prop.reaction:
		"wobble":
			tween.tween_property(sp, "rotation", deg_to_rad(-6), 0.08)
			tween.tween_property(sp, "rotation", deg_to_rad(5), 0.12)
			tween.tween_property(sp, "rotation", deg_to_rad(-2), 0.10)
			tween.tween_property(sp, "rotation", 0.0, 0.10)
		"shake":
			tween.tween_property(sp, "position:x", sp.position.x + 4, 0.05)
			tween.tween_property(sp, "position:x", sp.position.x - 4, 0.05)
			tween.tween_property(sp, "position:x", sp.position.x + 3, 0.05)
			tween.tween_property(sp, "position:x", sp.position.x, 0.05)
		"sway":
			tween.tween_property(sp, "skew", deg_to_rad(-12), 0.4)
			tween.tween_property(sp, "skew", 0.0, 0.6)
		"flare":
			tween.tween_property(sp, "modulate", Color(1.6, 1.4, 1.0, 1.0), 0.15)
			tween.tween_property(sp, "modulate", Color(1, 1, 1, 1), 0.4)

# ============ Layer 3 reveals ============
func _on_reveal_input(_viewport: Node, event: InputEvent, _shape_idx: int, reveal: Dictionary) -> void:
	if not (event is InputEventMouseButton): return
	if not event.pressed: return
	if event.button_index != MOUSE_BUTTON_LEFT: return
	_open_reveal(reveal)

func _open_reveal(reveal: Dictionary) -> void:
	if reveal.get("opened", false): return
	reveal.opened = true
	reveal.area.input_pickable = false
	_hint_system.mark_reveal_open(reveal.id)
	# Swap to open sprite via quick fade
	var sp: Sprite2D = reveal.sprite
	if sp != null and reveal.sprite_open_path != "" and ResourceLoader.exists(reveal.sprite_open_path):
		var tween := create_tween()
		tween.tween_property(sp, "modulate:a", 0.0, 0.18)
		tween.tween_callback(func() -> void:
			sp.texture = load(reveal.sprite_open_path))
		tween.tween_property(sp, "modulate:a", 1.0, 0.18)
	# Reveal items inside
	await get_tree().create_timer(0.4).timeout
	for child in hidden_objects.get_children():
		if not (child is Area2D): continue
		if "in_reveal" not in child: continue
		if child.in_reveal != reveal.id: continue
		var fade := create_tween()
		fade.tween_property(child, "modulate:a", 1.0, 0.4)
		child.input_pickable = true
		# Strip the "?" prefix from the list row
		var row: Label = _row_by_id.get(child.object_id, null)
		if row != null and row.text.begins_with("? "):
			row.text = row.text.substr(2)

# ============ Cursor parallax + lantern flicker ============
func _process(delta: float) -> void:
	if parallax != null:
		var viewport := get_viewport()
		if viewport != null:
			var size := viewport.get_visible_rect().size
			var mouse := viewport.get_mouse_position()
			var offset := Vector2(
				(mouse.x / size.x - 0.5) * -parallax_strength,
				(mouse.y / size.y - 0.5) * -parallax_strength * 0.6
			)
			parallax.scroll_offset = parallax.scroll_offset.lerp(offset, 0.15)
	# Lantern flicker
	if lantern_glow != null:
		_flicker_t += delta * 9.0
		var n := sin(_flicker_t) * 0.5 + sin(_flicker_t * 2.3 + 1.0) * 0.3
		lantern_glow.energy = 0.75 + n * 0.25

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
