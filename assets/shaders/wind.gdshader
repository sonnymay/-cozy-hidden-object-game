// Wind shader — sin-wave UV displacement.
// Apply to a CanvasItem (Sprite2D). The horizontal displacement increases
// from top (anchor) to bottom, simulating fabric sway.
shader_type canvas_item;

uniform float strength : hint_range(0.0, 0.05) = 0.008;
uniform float speed = 1.0;
uniform float frequency = 2.0;

void fragment() {
	float t = TIME * speed;
	// Sway grows with distance from top edge (UV.y close to 0 = top = anchored)
	float sway = sin(t * frequency + UV.y * 6.0) * strength * UV.y;
	vec2 displaced = vec2(UV.x + sway, UV.y);
	COLOR = texture(TEXTURE, displaced);
}
