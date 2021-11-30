shader_type canvas_item;

uniform vec2 mch_pos;
float circle(vec2 pos,float radius){
	return smoothstep(radius,radius-0.2,length(pos));
}

void fragment(){
	COLOR = (texture(TEXTURE,UV)); 
	if (COLOR.a != 0.0){
		COLOR.a -= circle(UV - vec2(normalize(mch_pos).x - 0.3,0.5),0.5) ;
	}
}