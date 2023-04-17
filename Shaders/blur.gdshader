shader_type canvas_item;

uniform sampler2D noise: repeat_enable;
uniform sampler2D noise2: repeat_enable;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform vec2 speed = vec2(1.0, 1.0);
uniform float distort_scale = 0.0;

void fragment() {
	vec4 noise_texture = texture(noise, UV+speed*TIME);
	vec4 noise_texture2 = texture(noise2, UV-speed*TIME);
	vec2 distorted_uv = (SCREEN_UV-distort_scale/100.0)+noise_texture.r*distort_scale/100.0+noise_texture2.r*distort_scale/100.0;
	vec4 screen_distorted = texture(screen_texture, distorted_uv);
	vec4 screen = texture(screen_texture, SCREEN_UV);
	COLOR.rgb=vec3(screen_distorted.rgb);
	COLOR.a = 1.0;
}
