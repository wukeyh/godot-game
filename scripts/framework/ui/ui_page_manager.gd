class_name UIPageManager
extends RefCounted

const PageScript = preload("res://scripts/framework/ui/ui_page.gd")

signal page_changed(previous_id: StringName, current_id: StringName)

var current_page: PageScript
var current_id: StringName = &""
var _root: Control
var _scenes: Dictionary = {}
var _switching := false


func initialize(page_root: Control) -> bool:
	if is_instance_valid(_root) or page_root == null:
		return false
	_root = page_root
	return true


func register_page(key: StringName, scene: PackedScene) -> bool:
	if key == &"" or scene == null or _scenes.has(key):
		return false
	_scenes[key] = scene
	return true


func switch_to(key: StringName, params: Dictionary = {}) -> bool:
	if _switching or not _scenes.has(key) or not is_instance_valid(_root):
		return false
	if current_id == key and is_instance_valid(current_page):
		return true
	var instance: Node = _scenes[key].instantiate()
	if not instance is PageScript:
		instance.free()
		return false
	if mount_page(key, instance, params):
		return true
	instance.free()
	return false


# Transfers ownership of a page instance to this manager.
func mount_page(key: StringName, page: PageScript, params: Dictionary = {}) -> bool:
	if _switching or key == &"" or not is_instance_valid(_root) or page == null or page == current_page:
		return false
	_switching = true
	var previous_id := current_id
	_release_current()
	if page.get_parent() != null:
		page.reparent(_root)
	else:
		_root.add_child(page)
	page.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	current_page = page
	current_id = key
	page.open(params)
	_switching = false
	page_changed.emit(previous_id, current_id)
	return true


func close_current(expected_page: PageScript = null) -> bool:
	if _switching or not is_instance_valid(current_page):
		return false
	if expected_page != null and current_page != expected_page:
		return false
	_switching = true
	var previous_id := current_id
	_release_current()
	_switching = false
	page_changed.emit(previous_id, &"")
	return true


func dispose() -> void:
	close_current()
	_scenes.clear()
	_root = null


func _release_current() -> void:
	if is_instance_valid(current_page):
		current_page.close()
		if current_page.get_parent() != null:
			current_page.get_parent().remove_child(current_page)
		current_page.queue_free()
	current_page = null
	current_id = &""
