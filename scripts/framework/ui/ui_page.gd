class_name UIPage
extends "res://scripts/framework/ui/ui_widget.gd"

const WidgetScript = preload("res://scripts/framework/ui/ui_widget.gd")

var _widgets: Dictionary = {}
var _default_widgets: Array[StringName] = []


func register_widget(key: StringName, widget: WidgetScript, open_by_default: bool = true) -> bool:
	if key == &"" or widget == null or _widgets.has(key) or not is_ancestor_of(widget):
		return false
	_widgets[key] = widget
	widget.hide()
	widget.process_mode = Node.PROCESS_MODE_DISABLED
	if open_by_default:
		_default_widgets.append(key)
	if is_open() and open_by_default:
		widget.open()
	return true


func get_widget(key: StringName) -> WidgetScript:
	return _widgets.get(key)


func open_widget(key: StringName, params: Dictionary = {}) -> bool:
	var widget := get_widget(key)
	if not is_open() or not is_instance_valid(widget):
		return false
	widget.open(params)
	return true


func close_widget(key: StringName) -> bool:
	var widget := get_widget(key)
	if not is_instance_valid(widget):
		return false
	widget.close()
	return true


func on_open(params: Dictionary) -> void:
	for key in _default_widgets:
		open_widget(key, params)


func on_close() -> void:
	for widget in _widgets.values():
		if is_instance_valid(widget):
			widget.close()
