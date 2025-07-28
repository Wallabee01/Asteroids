shader_type canvas_item;
render_mode blend_add;

uniform float intensity = 5.0;
uniform vec2 texture_size = vec2(16.0, 16.0); // Set to your actual sprite size

void fragment() {
    vec2 pixel_size = 1.0 / texture_size;

    vec4 tex_color = texture(TEXTURE, UV);

    // Add neighboring samples for glow simulation
    vec4 glow = tex_color;
    glow += texture(TEXTURE, UV + vec2(pixel_size.x, 0.0)) * 0.3;
    glow += texture(TEXTURE, UV - vec2(pixel_size.x, 0.0)) * 0.3;
    glow += texture(TEXTURE, UV + vec2(0.0, pixel_size.y)) * 0.3;
    glow += texture(TEXTURE, UV - vec2(0.0, pixel_size.y)) * 0.3;

    glow.rgb *= intensity;
    glow.a = tex_color.a; // Preserve alpha

    COLOR = glow;
}
