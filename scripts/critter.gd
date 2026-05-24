extends Sprite2D

# A small autonomous critter. State machine: idle → action → idle on a randomized
# timer. Action depends on `behaviour`:
#   - "hop": small jump arc, optionally flipping H every few hops
#   - "stretch": grow scale 1.0 → 1.15 → 1.0 over 1.2s (cat sleeping/stretching)
#   - "dart": fast translate from current position to a paired waypoint and back
#   - "drift": continuous diagonal float in a sine path across the scene
#
# Each critter has its own internal Tween.

enum State { IDLE, ACTING }

@export var behaviour: String = "hop"
@export var idle_min: float = 4.0
@export var idle_max: float = 9.0
@export var waypoint_offset: Vector2 = Vector2(200, 0)  # for "dart" — second position relative to start
@export var drift_amplitude: float = 80.0               # for "drift" — sine amplitude
@export var drift_speed: float = 0.7                    # for "drift" — cycles per second
@export var hop_height: float = 40.0
@export var stretch_amount: float = 0.18

var _state: int = State.IDLE
var _next_t: float = 0.0
var _time: float = 0.0
var _base_pos: Vector2
var _base_scale: Vector2
var _drift_t: float = 0.0
var _drift_start: Vector2

func _ready() -> void:
	_base_pos = position
	_base_scale = scale
	_drift_start = position
	_next_t = randf_range(idle_min, idle_max) * 0.3 # first action soon

func _process(delta: float) -> void:
	_time += delta
	if behaviour == "drift":
		_drift_t += delta * drift_speed
		# Translate across the scene in a soft horizontal sine
		var dx := sin(_drift_t * TAU * 0.15) * drift_amplitude * 6.0
		var dy := sin(_drift_t * TAU * 0.5) * drift_amplitude * 0.6
		position = _drift_start + Vector2(dx, dy)
		rotation = sin(_drift_t * TAU * 0.5) * 0.15
		return
	if _state == State.IDLE and _time >= _next_t:
		_state = State.ACTING
		_perform_action()

func _perform_action() -> void:
	match behaviour:
		"hop":     _do_hop()
		"stretch": _do_stretch()
		"dart":    _do_dart()
		_:         _finish_action()

func _do_hop() -> void:
	var tw := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# Lean back (anticipation)
	tw.tween_property(self, "scale", Vector2(_base_scale.x * 1.08, _base_scale.y * 0.92), 0.10)
	# Hop forward + up (move 30px in facing direction)
	var dir := -1.0 if flip_h else 1.0
	tw.tween_property(self, "position", _base_pos + Vector2(30 * dir, -hop_height), 0.18)
	# Land
	tw.tween_property(self, "position", _base_pos + Vector2(30 * dir, 0), 0.10)
	# Squash on landing
	tw.tween_property(self, "scale", Vector2(_base_scale.x * 1.10, _base_scale.y * 0.90), 0.06)
	tw.tween_property(self, "scale", _base_scale, 0.10)
	# Reset base + occasionally flip direction
	tw.tween_callback(func() -> void:
		_base_pos = position
		if randf() < 0.35:
			flip_h = not flip_h
		_finish_action())

func _do_stretch() -> void:
	# Slow inhale → big stretch → settle
	var tw := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(self, "scale", Vector2(_base_scale.x * (1.0 + stretch_amount), _base_scale.y * (1.0 - stretch_amount * 0.4)), 0.6)
	tw.tween_interval(0.3)
	tw.tween_property(self, "scale", _base_scale, 0.6)
	tw.tween_callback(_finish_action)

func _do_dart() -> void:
	var target := _base_pos + waypoint_offset
	var tw := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# Anticipation lean
	tw.tween_property(self, "scale", Vector2(_base_scale.x * 1.05, _base_scale.y * 0.95), 0.08)
	# Fast dart there
	tw.tween_property(self, "position", target, 0.32)
	# Stop briefly
	tw.tween_interval(randf_range(0.3, 1.0))
	# Dart back
	tw.tween_property(self, "position", _base_pos, 0.32)
	tw.tween_property(self, "scale", _base_scale, 0.08)
	tw.tween_callback(_finish_action)

func _finish_action() -> void:
	_state = State.IDLE
	_next_t = _time + randf_range(idle_min, idle_max)
