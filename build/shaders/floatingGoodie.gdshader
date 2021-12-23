shader_type canvas_item;




void vertex(){
	VERTEX += vec2(sin(TIME*8.0f),cos(TIME*16.0f)*4.0f);
}