shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

uniform float scale: hint_range(0.0, 2.0, 0.1) = 1;
uniform float flash;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform sampler2D noise_texture : repeat_enable;
void fragment() {
	// Called for every pixel the material is visible on.
	//vec2 distorted_uv = UV;
	//distorted_uv.x += UV.y + 0.4;
	//vec4 pixelColor = texture(TEXTURE, distorted_uv);
	//COLOR = pixelColor;
	
	// black and white
	//vec4 pixelColor = texture(TEXTURE, UV);
	//float value = (pixel_color.r + pixel_color.g + pixel_color.b) / 3.0;
	//COLOR = vec4(value, value, value, pixel_color.a);
	//COLOR = mix(pixelColor, vec4(1), flash)
	//COLOR.a = pixelColor.a
	vec2 distortedUV = SCREEN_UV + texture(TEXTURE, UV).r * 0.1;
	vec4 pixelColor = texture(screen_texture, distortedUV);
	COLOR.rgb = pixelColor.bgr;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
