class_name UIWidget
extends Control

signal opened
signal closed

var _open := false


func open(params: Dictionary = {}) -> void:
	if _open:
		return
	_open = true
	show()
	process_mode = Node.PROCESS_MODE_INHERIT
	on_open(params)
	opened.emit()


func close() -> void:
	if not _open:
		return
	_open = false
	on_close()
	var viewport := get_viewport()
	var focus: Control = viewport.gui_get_focus_owner() if viewport != null else null
	if focus != null and (focus == self or is_ancestor_of(focus)):
		focus.release_focus()
	hide()
	process_mode = Node.PROCESS_MODE_DISABLED
	closed.emit()


func is_open() -> bool:
	return _open


func on_open(_params: Dictionary) -> void:
	pass


func on_close() -> void:
	pass
