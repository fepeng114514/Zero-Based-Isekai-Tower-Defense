shader_type canvas_item;

uniform float outline_size : hint_range(0, 20) = 20.0;
uniform vec4 outline_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    vec2 pixel_size = 1.0 / TEXTURE_PIXEL_SIZE;
    
    float alpha = 0.0;
    
    // 检查周围像素的 alpha
    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            if (x == 0 && y == 0) continue;
            vec2 offset = vec2(float(x), float(y)) * outline_size * pixel_size;
            alpha += texture(TEXTURE, UV + offset).a;
        }
    }
    
    alpha = clamp(alpha, 0.0, 1.0);
    
    vec4 outline = vec4(outline_color.rgb, alpha * outline_color.a);
    COLOR = mix(color, outline, alpha);
}