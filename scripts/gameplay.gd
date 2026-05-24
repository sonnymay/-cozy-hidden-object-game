extends Node2D

@export var scene_data_path: String = "res://data/scene_01.json"
@export var parallax_strength: float = 30.0

@onready var parallax: ParallaxBackground = $Parallax
@onready var hidden_objects: Node2D = $HiddenObjects
@onready var particles: GPUParticles2D = $Particles/FoundSparkle
@onready var object_list: VBoxContainer = $HUD/Panel/ObjectList
@onready var hint_button: Button = $HUD/HintButton
@onready var hint_label: Label = $HUD/HintLabel
@onready var pulse: Node2D = $HUD/HintPulse
@onready var completion_panel: Panel = $HUD/CompletionPanel
@onready var completion_label: Label = $HUD/CompletionPanel/VBox/Label
@onready var chime: AudioStreamPlayer = $Chime

const ClickableScript := preload("res://scripts/object_clickable.gd")
const SceneLoader := preload("res://scripts/scene_loader.gd")
const HintSystemScript := preload("res://scripts/hint_system.gd")

var _hint_system: Node
var _row_by_id: Dictionary = {}

func _ready() -> void:
	_hint_system = HintSystemScript.new()
	add_child(_hint_system)
	_hint_system.bind(hidden_objects)
	_hint_system.pulse_at.connect(_on_pulse_at)
	_hint_system.cooldown_tick.connect(_on_cooldown_tick)

	var data := SceneLoader.load_scene_data(scene_data_path)
	if data.is_empty():
		return

	# Background is now 5 layered ParallaxLayer Sprites authored in gameplay.tscn.
	# JSON's legacy "background" key is ignored on purpose.

	var areas: Array = SceneLoader.populate(hidden_objects, data, ClickableScript)
	GameManager.start_scene(data.get("scene_id", "scene_01"), areas.size())
	_build_object_list(areas)

	for area in areas:
		area.found.connect(_on_object_found.bind(area))

	hint_button.pressed.connect(_on_hint_pressed)
	GameManager.scene_complete.connect(_on_scene_complete)
	completion_panel.visible = false
	_update_hint_label()

func _build_object_list(areas: Array) -> void:
	for child in object_list.get_children():
		child.queue_free()
	for area in areas:
		var lbl := Label.new()
		lbl.text = area.display_name
		object_list.add_child(lbl)
		_row_by_id[area.object_id] = lbl

func _on_object_found(area: Area2D) -> void:
	# Strikethrough via theme override
	var row: Label = _row_by_id.get(area.object_id, null)
	if row != null:
		row.modulate = Color(0.5, 0.5, 0.5, 0.7)
		row.text = "✓ " + row.text
	# Sparkle at position
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
	completion_label.text = "Scene complete!\nFound %d/%d\nHints used: %d" % [
		GameManager.found_ids.size(), GameManager.total_objects, hints_used
	]
	completion_panel.visible = true

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _process(_delta: float) -> void:
	# Cursor parallax: shift the ParallaxBackground a few px based on mouse
	# offset from viewport center. Each ParallaxLayer's motion_scale
	# multiplies this, producing depth.
	if parallax == null:
		return
	var viewport := get_viewport()
	if viewport == null:
		return
	var size := viewport.get_visible_rect().size
	var mouse := viewport.get_mouse_position()
	var offset := Vector2(
		(mouse.x / size.x - 0.5) * -parallax_strength,
		(mouse.y / size.y - 0.5) * -parallax_strength * 0.6
	)
	parallax.scroll_offset = parallax.scroll_offset.lerp(offset, 0.15)
