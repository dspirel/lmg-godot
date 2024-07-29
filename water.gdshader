shader_type canvas_item;
uniform vec2 tiled_factor = vec2(5.0);
uniform float aspect_ratio;

uniform sampler2D noise :repeat_enable;
uniform sampler2D noise2 :repeat_enable;
uniform float distortion_strength :hint_range(0.0, 2.0, 0.1) = 0.5;
uniform vec2 scroll_speed = vec2(0.05,0.0);

void fragment() {
	vec2 tiled_uvs = UV * tiled_factor;
	tiled_uvs.y *= aspect_ratio;
	vec4 noise_distortion = texture(noise2,(tiled_uvs + TIME * scroll_speed * 1.5)) * distortion_strength;
	vec4 noise_col = texture(noise, tiled_uvs + noise_distortion.rr * 0.05 + TIME * scroll_speed);
	vec4 water_col = texture(TEXTURE, UV);
//	COLOR = vec4(pixelated_uv, 0.0, 1.0);
//	COLOR = noise_col;
//	COLOR = vec4(fuv,0.0,1.0);
	COLOR = water_col + vec4(noise_col.r * 0.6,noise_col.g * 0.2,(noise_col.b + noise_distortion.r) * 0.8,1.0);

	

//	COLOR = texture(TEXTURE, tiled_uvs + waves_uv_offset * amplitude);
//	NORMAL_MAP = texture(NORMAL_TEXTURE, tiled_uvs + waves_uv_offset * amplitude).rgb;
//	COLOR = vec4(tiled_uvs, 0.0, 1.0);
}
