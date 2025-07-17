shader_type canvas_item;

uniform bool flash = false;

uniform float flash_strength : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    vec4 tex = texture(TEXTURE, UV) * COLOR;
    if (flash) {
        tex.rgb = mix(tex.rgb, vec3(1.0), flash_strength);
    }
    COLOR = tex;
}