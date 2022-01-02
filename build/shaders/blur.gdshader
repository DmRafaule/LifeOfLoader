shader_type canvas_item;

uniform float blur_amount : hint_range(-2.0, 10.0);
uniform float mix_amount : hint_range(0.0, 1.0);
uniform vec4 color_over : hint_color;

void fragment() {
	vec4 blurred = textureLod(SCREEN_TEXTURE, SCREEN_UV, 1.0);
	vec4 fin = mix(blurred, vec4(mix_amount), blur_amount);
	COLOR = fin;
}