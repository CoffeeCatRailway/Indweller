shader_type canvas_item;

uniform sampler2D screenTex : hint_screen_texture, repeat_enable;

uniform vec2 scale;
uniform float yZoom;

uniform vec4 waterColor : source_color;

void fragment()
{
	float uvHeight = SCREEN_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.y;
	vec2 reflectedUV = vec2(SCREEN_UV.x, SCREEN_UV.y - uvHeight * UV.y * yZoom * scale.y * 2.0);

    vec4 reflection = texture(screenTex, reflectedUV);
	COLOR.rgb = mix(reflection.rgb, waterColor.rgb, waterColor.a);
}
