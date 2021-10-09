shader_type canvas_item;

void fragment(){
	COLOR = texture(TEXTURE,UV);
	COLOR -= vec4(smoothstep(0.0,UV.x - 0.033,0.1) * .3);
}