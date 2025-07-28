shader_type canvas_item;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    // Boost brightness, clamp so no bleeding glow
    COLOR = vec4(min(tex_color.rgb * 5.0, vec3(5.0)), tex_color.a);
}
