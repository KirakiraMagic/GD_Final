shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 uv = FRAGCOORD.xy / SCREEN_PIXEL_SIZE;
	vec2 center = vec2(0.5, 0.5);
	float radius = 0.4;
	float dist = distance(uv, center);

	if (dist < radius) {
		vec2 direction = normalize(center - uv);
		uv += direction * 0.01 * sin(TIME * 2.0 + dist * 10.0);
	} else {
		vec2 noise_uv = uv * 10.0 + vec2(TIME * 0.1, TIME * 0.1);
		float noise = texture(NOISE_TEXTURE, noise_uv).r;
		vec2 flow_direction = normalize(center - uv);
		uv += flow_direction * noise * 0.02;
	}

	COLOR = texture(TEXTURE, uv);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
