shader_type canvas_item;

uniform vec4 bg_color         : source_color = vec4(0.0,0.0,0.0,1.0);
uniform vec2 offset;
uniform float bigStarSlow     = 2.0;
uniform float mediumStarSlow  = 6.0;
uniform float smallStarSlow   = 8.0;

uniform float smallStarAmount  = 0.002;
uniform float mediumStarAmount = 0.01;
uniform float bigStarAmount    = 0.02;

/* NEW: overall tint (like Sprite.modulate) */
uniform vec4 modulate_color : source_color = vec4(1.0,1.0,1.0,1.0);
/* NEW: extra fade multiplier (0 = invisible, 1 = full) */
uniform float fade : hint_range(0.0,1.0) = 1.0;
/* OPTIONAL: brightness multiplier for stars only */
uniform float star_intensity : hint_range(0.0,3.0) = 1.0;

float rand(vec2 st){
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

void fragment(){
    vec2 normCoordBig    = FRAGCOORD.xy + floor(offset / bigStarSlow);
    vec2 normCoordMedium = FRAGCOORD.xy + floor(offset / mediumStarSlow);
    vec2 normCoordSmall  = FRAGCOORD.xy + floor(offset / smallStarSlow);

    float color = 0.0;

    // Medium stars
    float size = 20.0;
    float prob = 1.0 - mediumStarAmount;
    vec2 pos = floor(normCoordMedium / size);
    float starValue = rand(pos);

    if (starValue > prob){
        vec2 center = size * pos + vec2(size, size) * 0.5;
        float t = 0.9 + 0.2 * sin(TIME * 8.0 + (starValue - prob) / (1.0 - prob) * 45.0);
        color = 1.0 - distance(normCoordMedium, center) / (0.5 * size);
        color = color * t / (abs(normCoordMedium.y - center.y)) * t / (abs(normCoordMedium.x - center.x));
    }

    // Big stars
    size = 100.0;
    prob = 1.0 - bigStarAmount;
    pos = floor(normCoordBig / size);
    starValue = rand(pos);

    if (starValue > prob){
        vec2 center = size * pos + vec2(size, size) * 0.5;
        float t = 0.9 + 0.2 * sin(TIME * 8.0 + (starValue - prob) / (1.0 - prob) * 45.0);
        color = 1.0 - distance(normCoordBig, center) / (0.5 * size);
        color = color * t / (abs(normCoordBig.y - center.y)) * t / (abs(normCoordBig.x - center.x));
    }

    // Small stars
    if (rand(normCoordSmall / 20.0) > 1.0 - smallStarAmount){
        float r = rand(normCoordSmall);
        color = r * (0.85 * sin(TIME * (r * 5.0) + 720.0 * r) + 0.95);
    }

    // Stars base color (white scaled), apply intensity
    vec3 stars_rgb = vec3(color) * star_intensity;

    // Combine with background base color
    vec4 stars = vec4(stars_rgb, color);
    vec4 base  = bg_color + stars;

    // Apply modulate tint & fade
    vec4 final_col = base * modulate_color;
    final_col.a *= fade;          // extra global alpha control
    final_col.rgb *= fade;        // fade color toward transparent

    // Clamp to avoid HDR blowout if unwanted
    final_col = clamp(final_col, 0.0, 1.0);

    COLOR = final_col;
}