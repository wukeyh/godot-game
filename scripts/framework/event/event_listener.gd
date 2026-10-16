class_name EventListener
extends RefCounted
# Source: script/core/event/event_dispatcher.lua (listener record and invalidation)

var _module: StringName
var _type: StringName
var _priority := 0
var _sequence := 0
var _scope_id := 0
var _method: StringName
var _dispatcher: WeakRef
var _target: WeakRef
var _owner: WeakRef
var _scope: WeakRef
var _lifetime_nodes: Array[WeakRef] = []
var _active := false


func cancel() -> void:
	if not _active:
		return
	var dispatcher: Object = _dispatcher.get_ref()
	_invalidate()
	if is_instance_valid(dispatcher):
		dispatcher._remove_listener(self)


func is_active() -> bool:
	return _active and _has_live_objects()


func _configure(dispatcher: Object, module_name: StringName, event_type: StringName,
		callback: Callable, priority: int, sequence: int, scope: Object, owner: Object) -> void:
	_module = module_name
	_type = event_type
	_priority = priority
	_sequence = sequence
	_method = callback.get_method()
	_dispatcher = weakref(dispatcher)
	var target: Object = callback.get_object()
	_target = weakref(target)
	_owner = weakref(owner)
	if scope != null:
		_scope = weakref(scope)
		_scope_id = scope.get_instance_id()
	_active = true
	_watch_node(target)
	_watch_node(owner)
	_watch_node(scope)


func _has_live_objects() -> bool:
	if _dispatcher == null or not is_instance_valid(_dispatcher.get_ref()):
		return false
	if _target == null or _owner == null:
		return false
	var target: Object = _target.get_ref()
	if not object_is_alive(target) or not object_is_alive(_owner.get_ref()):
		return false
	if _scope != null and not object_is_alive(_scope.get_ref()):
		return false
	return target.has_method(_method)


func _invoke(payload: Variant) -> void:
	var target: Object = _target.get_ref()
	target.call(_method, payload)


func _watch_node(value: Object) -> void:
	if not value is Node:
		return
	for existing in _lifetime_nodes:
		if existing.get_ref() == value:
			return
	_lifetime_nodes.append(weakref(value))
	(value as Node).tree_exiting.connect(cancel)


func _invalidate() -> void:
	_active = false
	for reference in _lifetime_nodes:
		var node := reference.get_ref() as Node
		if is_instance_valid(node) and node.tree_exiting.is_connected(cancel):
			node.tree_exiting.disconnect(cancel)
	_lifetime_nodes.clear()
	_dispatcher = null
	_target = null
	_owner = null
	_scope = null


static func object_is_alive(value: Object) -> bool:
	return is_instance_valid(value) and not (value is Node and value.is_queued_for_deletion())
