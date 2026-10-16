@tool
extends TextureRect

const OUTLINE_SHADER := """
shader_type canvas_item;
uniform vec4 outline_color : source_color = vec4(0.45, 0.95, 0.9, 1.0);
uniform float outline_strength = 0.0;
void fragment() {
    vec4 base = texture(TEXTURE, UV);
    vec2 p = TEXTURE_PIXEL_SIZE * 2.0;
    float around = 0.0;
    around = max(around, texture(TEXTURE, UV + vec2(p.x, 0.0)).a);
    around = max(around, texture(TEXTURE, UV - vec2(p.x, 0.0)).a);
    around = max(around, texture(TEXTURE, UV + vec2(0.0, p.y)).a);
    around = max(around, texture(TEXTURE, UV - vec2(0.0, p.y)).a);
    float edge = step(0.02, around) * (1.0 - step(0.02, base.a));
    COLOR = mix(base, outline_color, edge * outline_strength);
}
"""

var _material: ShaderMaterial

func _ready() -> void:
    mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    mouse_filter = Control.MOUSE_FILTER_STOP
    var shader := Shader.new()
    shader.code = OUTLINE_SHADER
    _material = ShaderMaterial.new()
    _material.shader = shader
    _material.set_shader_parameter("outline_strength", 0.0)
    material = _material
    mouse_entered.connect(_set_hover.bind(true))
    mouse_exited.connect(_set_hover.bind(false))

func _set_hover(active: bool) -> void:
    if _material:
        _material.set_shader_parameter("outline_strength", 1.0 if active else 0.0)
