// Flicker shader — random brightness modulation for candle / lantern glow.
// Apply to a CanvasItem (Sprite2D, ColorRect, or PointLight2D-driven sprite).
shader_type canvas_item;

uniform float min_brightness : hint_range(0.0, 1.0) = 0.55;
uniform float max_brightness : hint_range(0.0, 2.0) = 1.0;
uniform float speed = 8.0;

void fragment() {
	float t = floor(TIME * speed);
	float r = fract(sin(t * 12.9898) * 43758.5453);
	float b = mix(min_brightness, max_brightness, r);
	vec4 c = texture(TEXTURE, UV);
	COLOR = vec4(c.rgb * b, c.a);
}
