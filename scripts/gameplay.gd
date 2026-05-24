extends Node2D

@export var scene_data_path: String = "res://data/scene_01.json"

@onready var background: Sprite2D = $Background
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
const AmbientChoreographerScript := preload("res://scripts/ambient_choreographer.gd")

# Per-prop ambient behaviours — what each prop does when no one is clicking.
# Keys are prop IDs from data/scene_01.json (current = living-room set).
const PROP_AMBIENTS := {
	"mantle_clock":  "wobble",      # rare tick nudge
	"floor_lamp":    "shimmer",     # rare brightness pulse
	"throw_pillow":  "breathe",     # gentle scale pulse
	"fireplace":     "flame_pulse", # rapid subtle shimmer (the fire)
	"vase":          "breathe",     # very gentle settle
	"plant":         "sway",        # continuous leaf sway
	"tea_on_table":  "steam_puff",  # occasional steam burst above the tray
	"blanket":       "breathe",     # gentle fabric breathing
	"book_stack":    "wobble",      # rare settle
	"picture_frame": "wobble",      # rare nudge
}

const HOVER_BRIGHTEN := 0.18 # value bumped on hover
const HOVER_SCALE   := 1.06  # sprite scale on hover

var _hint_system: Node
var _choreographer: Node
var _row_by_id: Dictionary = {}
var _props: Array = []
var _reveals: Array = []
var _reveal_by_id: Dictionary = {}
var _props_touched: Dictionary = {}
var _hover_count: int = 0
var _flicker_t: float = 0.0

# Particle process materials (lazy-init)
var _mat_steam: ParticleProcessMaterial
var _mat_sparkle: ParticleProcessMaterial
var _mat_splatter: ParticleProcessMaterial

func _ready() -> void:
	_hint_system = HintSystemScript.new()
	add_child(_hint_system)
	_hint_system.bind(hidden_objects)
	_hint_system.pulse_at.connect(_on_pulse_at)
	_hint_system.cooldown_tick.connect(_on_cooldown_tick)

	var data := SceneLoader.load_scene_data(scene_data_path)
	if data.is_empty():
		return

	_reveals = SceneLoader.populate_reveals(reveals_root, data)
	for r in _reveals:
		_reveal_by_id[r.id] = r
		r.area.input_event.connect(_on_reveal_input.bind(r))
		r.area.mouse_entered.connect(_on_reveal_hover.bind(r, true))
		r.area.mouse_exited.connect(_on_reveal_hover.bind(r, false))
	_hint_system.register_reveals(_reveals)

	_props = SceneLoader.populate_props(props_root, data)
	for p in _props:
		p.area.input_event.connect(_on_prop_input.bind(p))
		p.area.mouse_entered.connect(_on_prop_hover.bind(p, true))
		p.area.mouse_exited.connect(_on_prop_hover.bind(p, false))

	# Ambient choreographer — drives autonomous motion on every prop + mascot
	_choreographer = AmbientChoreographerScript.new()
	add_child(_choreographer)
	_choreographer.request_particles.connect(_spawn_particles)
	for p in _props:
		if p.sprite == null: continue
		var kind: String = PROP_AMBIENTS.get(p.id, "")
		if kind == "": continue
		var opts := {
			"is_busy_callable": Callable(self, "_is_prop_busy").bind(p),
		}
		if kind == "steam_puff":
			opts["particle_offset"] = Vector2(0, -80)
			opts["particle_kind"] = "steam"
		_choreographer.register(p.sprite, kind, opts)
	# Mascot + parallax overlay registration removed in living-room rewrite.
	# NPCs (reader, knitter, cat) are intentionally STATIC per user spec.

	var areas: Array = SceneLoader.populate(hidden_objects, data, ClickableScript)
	GameManager.start_scene(data.get("scene_id", "scene_01"), areas.size())
	_build_object_list(areas)
	for area in areas:
		area.found.connect(_on_object_found.bind(area))
		area.mouse_entered.connect(_on_object_hover.bind(area, true))
		area.mouse_exited.connect(_on_object_hover.bind(area, false))

	hint_button.pressed.connect(_on_hint_pressed)
	GameManager.scene_complete.connect(_on_scene_complete)
	completion_panel.visible = false
	prop_counter.text = "Delights: 0/%d" % _props.size()
	_update_hint_label()

func _is_prop_busy(prop: Dictionary) -> bool:
	return prop.get("hover_busy", false)

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

func _on_scene_complete(_scene_id: String, hints_used: int) -> void:
	completion_label.text = "Scene complete!\nFound %d/%d\nHints used: %d\nDelights touched: %d/%d" % [
		GameManager.found_ids.size(), GameManager.total_objects, hints_used,
		_props_touched.size(), _props.size()
	]
	completion_panel.visible = true

# ============ P1 — Hover feedback ============

func _set_cursor_hovered(on: bool) -> void:
	# Aggregate hover count so cursor doesn't flicker between adjacent elements
	if on:
		_hover_count += 1
	else:
		_hover_count = max(0, _hover_count - 1)
	Input.set_default_cursor_shape(
		Input.CURSOR_POINTING_HAND if _hover_count > 0 else Input.CURSOR_ARROW
	)

func _on_prop_hover(prop: Dictionary, entered: bool) -> void:
	_set_cursor_hovered(entered)
	var sp: Sprite2D = prop.sprite
	if sp == null: return
	var tween := create_tween()
	if entered:
		tween.tween_property(sp, "modulate", Color(1.0 + HOVER_BRIGHTEN, 1.0 + HOVER_BRIGHTEN, 1.0 + HOVER_BRIGHTEN, 1.0), 0.12)
		tween.parallel().tween_property(sp, "scale", Vector2(HOVER_SCALE, HOVER_SCALE), 0.12)
	else:
		tween.tween_property(sp, "modulate", Color(1, 1, 1, 1), 0.18)
		tween.parallel().tween_property(sp, "scale", Vector2.ONE, 0.18)

func _on_reveal_hover(reveal: Dictionary, entered: bool) -> void:
	if reveal.get("opened", false): return
	_set_cursor_hovered(entered)
	var sp: Sprite2D = reveal.sprite
	if sp == null: return
	var tween := create_tween()
	if entered:
		tween.tween_property(sp, "modulate", Color(1.2, 1.2, 1.2, 1.0), 0.12)
		tween.parallel().tween_property(sp, "scale", Vector2(1.03, 1.03), 0.12)
	else:
		tween.tween_property(sp, "modulate", Color(1, 1, 1, 1), 0.18)
		tween.parallel().tween_property(sp, "scale", Vector2.ONE, 0.18)

func _on_object_hover(area: Area2D, entered: bool) -> void:
	if not area.input_pickable: return
	_set_cursor_hovered(entered)
	var sprites: Array = []
	for child in area.get_children():
		if child is Sprite2D:
			sprites.append(child)
	if sprites.is_empty(): return
	var tween := create_tween()
	for sp in sprites:
		if entered:
			tween.parallel().tween_property(sp, "modulate", Color(1.2, 1.2, 1.2, sp.modulate.a), 0.10)
			tween.parallel().tween_property(sp, "scale", Vector2(HOVER_SCALE, HOVER_SCALE), 0.10)
		else:
			tween.parallel().tween_property(sp, "modulate", Color(1, 1, 1, sp.modulate.a), 0.15)
			tween.parallel().tween_property(sp, "scale", Vector2.ONE, 0.15)

# ============ P2 — Bespoke prop reactions ============

func _on_prop_input(_viewport: Node, event: InputEvent, _shape_idx: int, prop: Dictionary) -> void:
	if not (event is InputEventMouseButton): return
	if not event.pressed: return
	if event.button_index != MOUSE_BUTTON_LEFT: return
	if prop.get("hover_busy", false): return
	_props_touched[prop.id] = true
	prop_counter.text = "Delights: %d/%d" % [_props_touched.size(), _props.size()]
	if prop.caption != "":
		_spawn_caption(prop.position + Vector2(0, -120), prop.caption)
	_dispatch_reaction(prop)

func _dispatch_reaction(prop: Dictionary) -> void:
	var sp: Sprite2D = prop.sprite
	if sp == null: return
	prop.hover_busy = true
	match prop.id:
		# Living-room props (current scene_01)
		"mantle_clock":  _react_picture(prop, sp)  # tick-nudge feels like a frame straighten
		"floor_lamp":    _react_lantern(prop, sp)  # brightness flare
		"throw_pillow":  _react_flower(prop, sp)   # elastic squish
		"fireplace":     _react_lantern(prop, sp)  # flame brightens
		"vase":          _react_bell(prop, sp)     # gentle ring/sway
		"tea_on_table":  _react_kettle(prop, sp)   # steam burst
		"blanket":       _react_curtain(prop, sp)  # fabric sway
		"book_stack":    _react_drawer(prop, sp)   # settle motion
		"picture_frame": _react_picture(prop, sp)
		"plant":         _react_plant(prop, sp)
		# Legacy bakery prop IDs (preserved for backward compat if old JSON loads)
		"mixer":         _react_mixer(prop, sp)
		"bell":          _react_bell(prop, sp)
		"drawer":        _react_drawer(prop, sp)
		"curtain":       _react_curtain(prop, sp)
		"kettle":        _react_kettle(prop, sp)
		"lantern":       _react_lantern(prop, sp)
		"awning":        _react_awning(prop, sp)
		"flower_pot":    _react_flower(prop, sp)
		_:               _react_default(prop, sp)

func _release_after(prop: Dictionary, t: float) -> void:
	await get_tree().create_timer(t).timeout
	prop.hover_busy = false

func _react_mixer(prop: Dictionary, sp: Sprite2D) -> void:
	# Body shakes vertically + steam puff above
	var base := sp.position
	var tw := create_tween()
	for i in 6:
		tw.tween_property(sp, "position", base + Vector2(0, -3 if i % 2 == 0 else 3), 0.05)
	tw.tween_property(sp, "position", base, 0.06)
	_spawn_particles(prop.position + Vector2(0, -160), "steam")
	_release_after(prop, 0.45)

func _react_bell(prop: Dictionary, sp: Sprite2D) -> void:
	# Ring: rotate -35, +15, -8, 0
	var tw := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(sp, "rotation", deg_to_rad(-35), 0.10)
	tw.tween_property(sp, "rotation", deg_to_rad(20), 0.18)
	tw.tween_property(sp, "rotation", deg_to_rad(-10), 0.16)
	tw.tween_property(sp, "rotation", 0.0, 0.14)
	_spawn_particles(prop.position + Vector2(0, -40), "sparkle")
	_release_after(prop, 0.6)

func _react_drawer(prop: Dictionary, sp: Sprite2D) -> void:
	# Slide open: swap sprite to open, translate down 12, hold, swap closed, translate back
	var open_path: String = prop.sprite_open_path
	var base := sp.position
	if open_path != "" and ResourceLoader.exists(open_path):
		sp.texture = load(open_path)
	var tw := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(sp, "position", base + Vector2(0, 12), 0.18)
	tw.tween_interval(0.5)
	tw.tween_property(sp, "position", base, 0.18)
	tw.tween_callback(func() -> void:
		if prop.sprite_closed_path != "" and ResourceLoader.exists(prop.sprite_closed_path):
			sp.texture = load(prop.sprite_closed_path))
	_release_after(prop, 1.0)

func _react_curtain(prop: Dictionary, sp: Sprite2D) -> void:
	# Sweep aside via skew + translate, hold, fall back
	var tw := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(sp, "skew", deg_to_rad(-22), 0.35)
	tw.parallel().tween_property(sp, "position:x", sp.position.x - 30, 0.35)
	tw.tween_interval(0.6)
	tw.tween_property(sp, "skew", 0.0, 0.5)
	tw.parallel().tween_property(sp, "position:x", sp.position.x, 0.5)
	_release_after(prop, 1.6)

func _react_kettle(prop: Dictionary, sp: Sprite2D) -> void:
	# Rocks gently + steam burst
	var tw := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(sp, "rotation", deg_to_rad(-5), 0.18)
	tw.tween_property(sp, "rotation", deg_to_rad(5), 0.22)
	tw.tween_property(sp, "rotation", 0.0, 0.18)
	_spawn_particles(prop.position + Vector2(-30, -80), "steam")
	_release_after(prop, 0.7)

func _react_lantern(prop: Dictionary, sp: Sprite2D) -> void:
	# Flame brightens 2x for 0.5s, sparks puff out
	var tw := create_tween()
	tw.tween_property(sp, "modulate", Color(1.7, 1.5, 1.0, 1.0), 0.10)
	tw.tween_interval(0.3)
	tw.tween_property(sp, "modulate", Color(1, 1, 1, 1), 0.35)
	# Also kick the lantern PointLight2D briefly
	if lantern_glow != null:
		var lt := create_tween()
		lt.tween_property(lantern_glow, "energy", 1.6, 0.08)
		lt.tween_interval(0.3)
		lt.tween_property(lantern_glow, "energy", 0.85, 0.35)
	_spawn_particles(prop.position + Vector2(0, -20), "sparkle")
	_release_after(prop, 0.8)

func _react_picture(prop: Dictionary, sp: Sprite2D) -> void:
	# Tilts left, then snaps straight (as if user nudged it)
	var tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(sp, "rotation", deg_to_rad(-6), 0.15)
	tw.tween_property(sp, "rotation", 0.0, 0.4)
	_release_after(prop, 0.6)

func _react_plant(prop: Dictionary, sp: Sprite2D) -> void:
	# Leaves sway — alternating skew + scale pulse
	var tw := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(sp, "skew", deg_to_rad(8), 0.25)
	tw.tween_property(sp, "skew", deg_to_rad(-6), 0.30)
	tw.tween_property(sp, "skew", 0.0, 0.25)
	_release_after(prop, 0.85)

func _react_awning(prop: Dictionary, sp: Sprite2D) -> void:
	# Ripples like fabric — wave of skews
	var tw := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(sp, "skew", deg_to_rad(-7), 0.18)
	tw.tween_property(sp, "skew", deg_to_rad(7), 0.22)
	tw.tween_property(sp, "skew", deg_to_rad(-3), 0.18)
	tw.tween_property(sp, "skew", 0.0, 0.18)
	_release_after(prop, 0.8)

func _react_flower(prop: Dictionary, sp: Sprite2D) -> void:
	# Soft rotation wobble + sparkle pop
	var tw := create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(sp, "rotation", deg_to_rad(8), 0.5)
	tw.tween_property(sp, "rotation", 0.0, 0.6)
	_spawn_particles(prop.position + Vector2(0, -120), "sparkle")
	_release_after(prop, 1.1)

func _react_default(prop: Dictionary, sp: Sprite2D) -> void:
	var tw := create_tween()
	tw.tween_property(sp, "scale", Vector2(1.1, 1.1), 0.12)
	tw.tween_property(sp, "scale", Vector2.ONE, 0.18)
	_release_after(prop, 0.4)

# ============ Caption + particle helpers ============

func _spawn_caption(world_pos: Vector2, text: String) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	lbl.add_theme_constant_override("outline_size", 4)
	lbl.add_theme_font_size_override("font_size", 28)
	lbl.position = world_pos - Vector2(0, 0)
	add_child(lbl)
	# Center horizontally by adjusting after first frame
	lbl.size = Vector2.ZERO
	await get_tree().process_frame
	lbl.position.x -= lbl.size.x * 0.5
	var tw := create_tween()
	tw.tween_property(lbl, "position:y", lbl.position.y - 60, 1.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(lbl, "modulate:a", 0.0, 1.2)
	tw.tween_callback(func() -> void: lbl.queue_free())

func _spawn_particles(world_pos: Vector2, kind: String) -> void:
	var p := GPUParticles2D.new()
	p.position = world_pos
	p.amount = 18
	p.one_shot = true
	p.explosiveness = 0.9
	match kind:
		"steam":
			p.lifetime = 1.2
			p.process_material = _get_steam_material()
		"sparkle":
			p.lifetime = 0.8
			p.process_material = _get_sparkle_material()
		"splatter":
			p.lifetime = 0.7
			p.process_material = _get_splatter_material()
	add_child(p)
	p.restart()
	p.emitting = true
	# Auto-cleanup after lifetime + buffer
	await get_tree().create_timer(p.lifetime + 0.3).timeout
	p.queue_free()

func _get_steam_material() -> ParticleProcessMaterial:
	if _mat_steam == null:
		_mat_steam = ParticleProcessMaterial.new()
		_mat_steam.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
		_mat_steam.emission_sphere_radius = 20.0
		_mat_steam.direction = Vector3(0, -1, 0)
		_mat_steam.spread = 25.0
		_mat_steam.initial_velocity_min = 40.0
		_mat_steam.initial_velocity_max = 80.0
		_mat_steam.gravity = Vector3(0, -20, 0)
		_mat_steam.scale_min = 0.6
		_mat_steam.scale_max = 1.4
		_mat_steam.color = Color(1, 1, 1, 0.75)
	return _mat_steam

func _get_sparkle_material() -> ParticleProcessMaterial:
	if _mat_sparkle == null:
		_mat_sparkle = ParticleProcessMaterial.new()
		_mat_sparkle.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
		_mat_sparkle.emission_sphere_radius = 16.0
		_mat_sparkle.direction = Vector3(0, -1, 0)
		_mat_sparkle.spread = 180.0
		_mat_sparkle.initial_velocity_min = 60.0
		_mat_sparkle.initial_velocity_max = 140.0
		_mat_sparkle.gravity = Vector3(0, 60, 0)
		_mat_sparkle.scale_min = 0.4
		_mat_sparkle.scale_max = 1.0
		_mat_sparkle.color = Color(1, 0.94, 0.6, 1.0)
	return _mat_sparkle

func _get_splatter_material() -> ParticleProcessMaterial:
	if _mat_splatter == null:
		_mat_splatter = ParticleProcessMaterial.new()
		_mat_splatter.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
		_mat_splatter.emission_sphere_radius = 12.0
		_mat_splatter.direction = Vector3(0, -1, 0)
		_mat_splatter.spread = 75.0
		_mat_splatter.initial_velocity_min = 80.0
		_mat_splatter.initial_velocity_max = 160.0
		_mat_splatter.gravity = Vector3(0, 120, 0)
		_mat_splatter.scale_min = 0.5
		_mat_splatter.scale_max = 1.0
		_mat_splatter.color = Color(0.85, 0.6, 0.45, 0.9)
	return _mat_splatter

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
	var sp: Sprite2D = reveal.sprite
	if sp != null and reveal.sprite_open_path != "" and ResourceLoader.exists(reveal.sprite_open_path):
		var tween := create_tween()
		tween.tween_property(sp, "modulate:a", 0.0, 0.18)
		tween.tween_callback(func() -> void:
			sp.texture = load(reveal.sprite_open_path))
		tween.tween_property(sp, "modulate:a", 1.0, 0.18)
	_spawn_particles(reveal.position, "sparkle")
	await get_tree().create_timer(0.4).timeout
	for child in hidden_objects.get_children():
		if not (child is Area2D): continue
		if "in_reveal" not in child: continue
		if child.in_reveal != reveal.id: continue
		var fade := create_tween()
		fade.tween_property(child, "modulate:a", 1.0, 0.4)
		child.input_pickable = true
		var row: Label = _row_by_id.get(child.object_id, null)
		if row != null and row.text.begins_with("? "):
			row.text = row.text.substr(2)

# ============ Lantern flicker (ambient) ============

func _process(delta: float) -> void:
	# Parallax removed — single flat-iso background, no per-layer scroll.
	if lantern_glow != null:
		_flicker_t += delta * 9.0
		var n := sin(_flicker_t) * 0.5 + sin(_flicker_t * 2.3 + 1.0) * 0.3
		# Don't fight the reaction tween — only set when within ambient range
		if lantern_glow.energy <= 1.1:
			lantern_glow.energy = 0.75 + n * 0.15

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if _placement_mode:
			_set_placement_mode(false)
			return
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

# ============ PLACEMENT EDITOR (dev tool) ============
# F2 → toggle placement mode. In placement mode:
#   - Click + drag any item / prop / reveal to reposition
#   - Z while dragging cycles z_index 0..4
#   - S writes positions + z_index back to data/scene_01.json
#   - Esc exits placement mode

var _placement_mode: bool = false
var _placement_hud: Label = null
var _dragging_node: Node2D = null
var _drag_offset: Vector2 = Vector2.ZERO
var _disabled_pickable: Array = []

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F2:
			_set_placement_mode(not _placement_mode)
			return
		if not _placement_mode: return
		if event.keycode == KEY_S:
			_save_placements()
		elif event.keycode == KEY_Z and _dragging_node != null:
			_dragging_node.z_index = (_dragging_node.z_index + 1) % 5
			_update_placement_hud()

	if not _placement_mode: return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_placement_try_grab(get_viewport().get_mouse_position())
			else:
				_dragging_node = null
				_update_placement_hud()
	elif event is InputEventMouseMotion and _dragging_node != null:
		_dragging_node.global_position = get_viewport().get_mouse_position() + _drag_offset
		_update_placement_hud()

func _set_placement_mode(on: bool) -> void:
	_placement_mode = on
	if on:
		_disabled_pickable.clear()
		for area in _collect_all_areas():
			if area.input_pickable:
				_disabled_pickable.append(area)
				area.input_pickable = false
		Input.set_default_cursor_shape(Input.CURSOR_DRAG)
	else:
		for area in _disabled_pickable:
			if is_instance_valid(area):
				area.input_pickable = true
		_disabled_pickable.clear()
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	if on:
		if _placement_hud == null:
			_placement_hud = Label.new()
			_placement_hud.add_theme_font_size_override("font_size", 18)
			_placement_hud.add_theme_color_override("font_color", Color(1, 1, 1))
			_placement_hud.add_theme_color_override("font_outline_color", Color(0, 0, 0))
			_placement_hud.add_theme_constant_override("outline_size", 4)
			_placement_hud.position = Vector2(420, 16)
			$HUD.add_child(_placement_hud)
		_placement_hud.visible = true
		_update_placement_hud()
	else:
		_dragging_node = null
		if _placement_hud != null:
			_placement_hud.visible = false

func _collect_all_areas() -> Array:
	var out: Array = []
	for c in hidden_objects.get_children():
		if c is Area2D:
			out.append(c)
	for p in _props:
		out.append(p.area)
	for r in _reveals:
		out.append(r.area)
	return out

func _placement_try_grab(mouse_pos: Vector2) -> void:
	# Iterate candidate entities: hidden objects → props → reveals.
	# First match (closest to cursor) wins.
	var candidates: Array = []
	for c in hidden_objects.get_children():
		if c is Area2D:
			candidates.append({"node": c, "size": Vector2(128, 128)})
	for p in _props:
		candidates.append({"node": p.area, "size": _get_area_size(p.area)})
	for r in _reveals:
		candidates.append({"node": r.area, "size": _get_area_size(r.area)})
	var best: Node2D = null
	var best_dist: float = INF
	for cand in candidates:
		var n: Node2D = cand.node
		var half: Vector2 = cand.size * 0.5
		var rect := Rect2(n.global_position - half, cand.size)
		if rect.has_point(mouse_pos):
			var d := n.global_position.distance_to(mouse_pos)
			if d < best_dist:
				best_dist = d
				best = n
	if best != null:
		_dragging_node = best
		_drag_offset = best.global_position - mouse_pos
		_update_placement_hud()

func _get_area_size(area: Area2D) -> Vector2:
	for c in area.get_children():
		if c is CollisionShape2D and c.shape is RectangleShape2D:
			return c.shape.size
	return Vector2(128, 128)

func _update_placement_hud() -> void:
	if _placement_hud == null: return
	var status := "PLACEMENT MODE | S=save  Z=cycle z  Esc=exit"
	if _dragging_node != null:
		status += "\n%s @ (%d, %d) z=%d" % [
			_dragging_node.name,
			int(_dragging_node.global_position.x),
			int(_dragging_node.global_position.y),
			_dragging_node.z_index
		]
	_placement_hud.text = status

func _save_placements() -> void:
	# Re-read JSON, update position + z_index from current scene state, write back
	var path: String = scene_data_path
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("Cannot read %s" % path); return
	var text := f.get_as_text()
	f.close()
	var data: Variant = JSON.parse_string(text)
	if typeof(data) != TYPE_DICTIONARY:
		push_error("JSON parse failed"); return

	# Build lookup: id → current Node2D
	var id_to_node: Dictionary = {}
	for c in hidden_objects.get_children():
		if c is Area2D and "object_id" in c:
			id_to_node[c.object_id] = c
	for p in _props:
		id_to_node["prop:" + p.id] = p.area
	for r in _reveals:
		id_to_node["reveal:" + r.id] = r.area

	# Patch hidden_objects entries
	for entry in data.get("hidden_objects", []):
		var n: Node2D = id_to_node.get(entry.get("id", ""), null)
		if n != null:
			entry["position"] = [int(n.position.x), int(n.position.y)]
			if n.z_index != 0:
				entry["z_index"] = n.z_index
	for entry in data.get("props", []):
		var n: Node2D = id_to_node.get("prop:" + entry.get("id", ""), null)
		if n != null:
			entry["position"] = [int(n.position.x), int(n.position.y)]
			if n.z_index != 0:
				entry["z_index"] = n.z_index
	for entry in data.get("reveals", []):
		var n: Node2D = id_to_node.get("reveal:" + entry.get("id", ""), null)
		if n != null:
			entry["position"] = [int(n.position.x), int(n.position.y)]
			if n.z_index != 0:
				entry["z_index"] = n.z_index

	var out_text := JSON.stringify(data, "  ")
	var w := FileAccess.open(path, FileAccess.WRITE)
	if w == null:
		push_error("Cannot write %s" % path); return
	w.store_string(out_text)
	w.close()
	if _placement_hud != null:
		_placement_hud.text = "PLACEMENT MODE | SAVED → %s" % path
		await get_tree().create_timer(1.2).timeout
		_update_placement_hud()
