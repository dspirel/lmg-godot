shader_type canvas_item;

uniform sampler2D noise :repeat_enable;
uniform sampler2D noise2 :repeat_enable;
uniform sampler2D noise3 :repeat_enable;

void fragment() {
	vec4 tnoise2 = texture(noise2, UV + TIME * 0.05);
	vec4 tnoise = texture(noise, UV + TIME * 0.02 + tnoise2.rr * 0.01);
	tnoise.rgb = smoothstep(vec3(0.75),vec3(1.0),tnoise.rgb);
	vec4 tex = texture(TEXTURE, UV);
	vec4 depth_color = texture(noise3,UV + vec2(TIME * 0.05,TIME * 0.02));
	COLOR = vec4((depth_color.rgb/4.0) + tex.rgb + tnoise.rgb * 0.4,tex.a);
}
