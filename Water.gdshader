shader_type spatial;

const vec3 base_color = vec3(0.05, 0.35, 0.85); // bluish base
const float amplitude = 0.25;
const float frequency = 4.0;
const float speed = 1.0;
const float noise_scale = 2.0;
const float noise_amp = 0.08;
const float roughness = 0.5;
const float metallic = 0.0;

render_mode blend_mix, depth_draw_opaque, cull_back;

// Declare our own varying
varying float v_tint;

void vertex() {

}

void fragment() {
	ALBEDO = base_color;
	ALPHA = 0.5;
	ROUGHNESS = roughness;
	METALLIC = metallic;
}
