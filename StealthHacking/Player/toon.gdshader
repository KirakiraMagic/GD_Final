shader_type canvas_item;

uniform sampler2D gradient_fallof;

void light() {
	float calculated_light_value = max(0.0, dot(NORMAL, LIGHT_DIRECTION));
	float sample = clamp(calculated_light_value * LIGHT_ENERGY, 0.05, 0.95);
	vec4 shaded_texture = texture(gradient_fallof, vec2(sample, 0));
	LIGHT = vec4(LIGHT_COLOR.rgb * COLOR.rgb * shaded_texture.rgb, LIGHT_COLOR.a);
}