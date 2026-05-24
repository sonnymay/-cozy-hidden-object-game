extends Node

# Drives continuous autonomous motion on every prop in the scene.
# Each prop registers with a behaviour kind. We run an internal scheduler
# that re-triggers each behaviour on a per-prop randomized timer so the
# scene never sits still and animations never beat together.

var _entries: Array = [] # Array of Dictionary { sprite, kind, next_t, hover_busy_check }
var _time: float = 0.0

const BEHAVIOURS := {
	"breathe":     { "min": 3.0, "max": 5.0 },  # gentle scale pulse
	"sway":        { "min": 2.4, "max": 4.2 },  # skew oscillation
	"steam_puff":  { "min": 7.0, "max": 11.0 }, # spawn steam particle burst (handled via callback)
	"wobble":      { "min": 9.0, "max": 16.0 }, # tiny rotation drift then correct
	"flame_pulse": { "min": 0.6, "max": 1.4 },  # very fast subtle scale + brightness shimmer
	"bob":         { "min": 2.6, "max": 2.6 },  # mascot idle bob (rhythmic, not random)
	"shimmer":     { "min": 6.0, "max": 12.0 }, # rare brief modulate brighten
}

signal request_particles(world_pos: Vector2, kind: String)

func register(sprite: Node2D, kind: String, opts: Dictionary = {}) -> void:
	if sprite == null: return
	if not (kind in BEHAVIOURS):
		push_warning("Unknown ambient kind: %s" % kind)
		return
	var entry := {
		"sprite": sprite,
		"kind": kind,
		"next_t": _time + randf_range(0.0, 2.5),
		"is_busy_callable": opts.get("is_busy_callable", null),
		"particle_offset": opts.get("particle_offset", Vector2.ZERO),
		"particle_kind": opts.get("particle_kind", "steam"),
		"base_scale": sprite.scale if sprite is Node2D else Vector2.ONE,
		"base_pos": sprite.position if sprite is Node2D else Vector2.ZERO,
	}
	_entries.append(entry)

func _process(delta: float) -> void:
	_time += delta
	for e in _entries:
		if e.next_t > _time: continue
		# Skip if the prop is in the middle of a click reaction
		if e.is_busy_callable != null and e.is_busy_callable.call():
			e.next_t = _time + 0.4
			continue
		_fire(e)
		var spec: Dictionary = BEHAVIOURS[e.kind]
		e.next_t = _time + randf_range(spec.min, spec.max)

func _fire(e: Dictionary) -> void:
	var sp: Node2D = e.sprite
	if sp == null or not is_instance_valid(sp): return
	match e.kind:
		"breathe":   _ambient_breathe(sp, e.base_scale)
		"sway":      _ambient_sway(sp)
		"steam_puff":
			request_particles.emit(sp.global_position + e.particle_offset, e.particle_kind)
		"wobble":    _ambient_wobble(sp)
		"flame_pulse": _ambient_flame(sp, e.base_scale)
		"bob":       _ambient_bob(sp, e.base_pos)
		"shimmer":   _ambient_shimmer(sp)

# -- per-behaviour animation chains (all use the engine's create_tween via the
#    node so they auto-clean when the node frees) --

func _ambient_breathe(sp: Node2D, base: Vector2) -> void:
	var tw := sp.create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(sp, "scale", base * 1.025, 1.2)
	tw.tween_property(sp, "scale", base, 1.2)

func _ambient_sway(sp: Node2D) -> void:
	if not ("skew" in sp): return
	var tw := sp.create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(sp, "skew", deg_to_rad(4), 0.9)
	tw.tween_property(sp, "skew", deg_to_rad(-3), 1.1)
	tw.tween_property(sp, "skew", 0.0, 0.8)

func _ambient_wobble(sp: Node2D) -> void:
	var tw := sp.create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(sp, "rotation", deg_to_rad(2.5), 0.4)
	tw.tween_property(sp, "rotation", deg_to_rad(-1.5), 0.5)
	tw.tween_property(sp, "rotation", 0.0, 0.4)

func _ambient_flame(sp: Node2D, base: Vector2) -> void:
	var tw := sp.create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(sp, "scale", base * randf_range(0.98, 1.04), 0.18)
	tw.tween_property(sp, "scale", base, 0.18)

func _ambient_bob(sp: Node2D, base: Vector2) -> void:
	var tw := sp.create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(sp, "position", base + Vector2(0, -10), 1.3)
	tw.tween_property(sp, "position", base, 1.3)

func _ambient_shimmer(sp: Node2D) -> void:
	if not (sp is CanvasItem): return
	var tw := sp.create_tween()
	tw.tween_property(sp, "modulate", Color(1.15, 1.12, 1.05, 1.0), 0.25)
	tw.tween_property(sp, "modulate", Color(1, 1, 1, 1), 0.45)
