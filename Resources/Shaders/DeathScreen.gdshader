shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear;

void fragment() {
	vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec4 final_col = color;
	
	float avg = (final_col.r + final_col.g + final_col.b) / 3.0;
	vec3 desaturated = mix(vec3(avg), final_col.rgb, 0.0);
	final_col.rgb =  clamp(desaturated, 0.0, 1.0);
	
	COLOR = final_col;
}


//I have no idea what I am doing