shader_type canvas_item;

void fragment(){
	COLOR = texture(TEXTURE,UV);
	COLOR += vec4(vec3(sin(TIME)),sin(TIME));
	COLOR.rgb -= 0.9;
}