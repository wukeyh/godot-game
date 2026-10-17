@tool
extends Label

## Live system clock overlay for the NEXUS-7 display.
## @tool keeps the same clock visible in the Godot editor preview.

@export_category("Clock Appearance")
@export var display_scale := Vector2.ONE
@export_range(8, 256, 1) var font_size := 29
@export var clock_font: Font
@export var clock_color := Color(0.86, 0.98, 1.0, 1.0)

var _last_scale := Vector2.ZERO
var _last_font_size := -1
var _last_clock_font: Font
var _last_clock_color := Color.TRANSPARENT

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_apply_appearance()
	_refresh_time()


func _process(_delta: float) -> void:
	if display_scale != _last_scale or font_size != _last_font_size or clock_font != _last_clock_font or clock_color != _last_clock_color:
		_apply_appearance()
	var current_time := _get_clock_text()
	if text != current_time:
		text = current_time


func _refresh_time() -> void:
	text = _get_clock_text()


func _get_clock_text() -> String:
	return Time.get_time_string_from_system().substr(0, 5)


func _apply_appearance() -> void:
	_last_scale = display_scale
	_last_font_size = font_size
	_last_clock_font = clock_font
	_last_clock_color = clock_color
	scale = display_scale
	add_theme_font_size_override("font_size", font_size)
	add_theme_color_override("font_color", clock_color)
	remove_theme_color_override("font_shadow_color")
	remove_theme_constant_override("shadow_offset_x")
	remove_theme_constant_override("shadow_offset_y")
	if clock_font:
		add_theme_font_override("font", clock_font)
	else:
		remove_theme_font_override("font")
