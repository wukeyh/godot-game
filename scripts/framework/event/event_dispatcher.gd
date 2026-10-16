class_name EventDispatcher
extends RefCounted
# Source: script/core/event/event_dispatcher.lua

const Define = preload("res://scripts/framework/event/event_define.gd")
const Listener = preload("res://scripts/framework/event/event_listener.gd")

# module -> type -> ordered Array[EventListener].
var _modules: Dictionary = {}
var _pending: Array[Listener] = []
var _dispatch_stack: Array[Dictionary] = []
var _next_sequence := 0


func add_event_listener(module_name: StringName, event_type: StringName, callback: Callable,
		priority: int = 0, scope: Object = null, owner: Object = null) -> Listener:
	if module_name.is_empty() or event_type.is_empty():
		return null
	# Store a weak target + method, never a capturing Callable.
	if not callback.is_valid() or not callback.is_standard() or callback.get_argument_count() != 1:
		return null
	var target: Object = callback.get_object()
	# GDScript static methods can also be standard Callables, with Script as target.
	if target is Script:
		return null
	if owner == null:
		owner = target
	if not Listener.object_is_alive(target) or not Listener.object_is_alive(owner):
		return null
	if scope != null and not Listener.object_is_alive(scope):
		return null
	var listener := Listener.new()
	_next_sequence += 1
	listener._configure(self, module_name, event_type, callback, priority, _next_sequence, scope, owner)
	if _dispatch_stack.is_empty():
		_insert(listener)
	else:
		_pending.append(listener)
	return listener


func dispatch_event(module_name: StringName, event_type: StringName,
		payload: Variant = null, scope: Object = null) -> int:
	if module_name.is_empty() or event_type.is_empty():
		return Define.DispatchError.INVALID_ARGUMENT
	if scope != null and not Listener.object_is_alive(scope):
		return Define.DispatchError.INVALID_ARGUMENT
	var scope_id := scope.get_instance_id() if scope != null else 0
	for active in _dispatch_stack:
		if active.module == module_name and active.type == event_type and active.scope == scope_id:
			return Define.DispatchError.REENTRANT
	if _dispatch_stack.size() >= Define.MAX_DISPATCH_DEPTH:
		return Define.DispatchError.DEPTH_LIMIT
	_dispatch_stack.append({"module": module_name, "type": event_type, "scope": scope_id})
	var called := 0
	var handlers: Array = _get_handlers(module_name, event_type).duplicate()
	for listener: Listener in handlers:
		if listener._scope_id == scope_id and listener.is_active():
			listener._invoke(payload)
			called += 1
	_dispatch_stack.pop_back()
	if _dispatch_stack.is_empty():
		prune_invalid_listeners()
		var pending := _pending
		_pending = []
		for listener in pending:
			_insert(listener)
	return called


func remove_event_listeners_by_module_and_type(module_name: StringName, event_type: StringName) -> int:
	return _clear_matching(&"event", module_name, event_type)


func remove_event_listeners_by_module(module_name: StringName) -> int:
	return _clear_matching(&"module", module_name)


func remove_all_event_listener() -> int:
	return _clear_matching(&"all")


func prune_invalid_listeners() -> int:
	var removed := 0
	# During dispatch keep records in place; active snapshots observe invalidation.
	for listener in _all_listeners():
		if not listener.is_active():
			listener._invalidate()
			removed += 1
	if _dispatch_stack.is_empty():
		_compact()
	return removed


func get_listener_count() -> int:
	var count := 0
	for listener in _all_listeners():
		if listener.is_active():
			count += 1
	return count


func _remove_listener(_listener: Listener) -> void:
	if _dispatch_stack.is_empty():
		_compact()


func _insert(listener: Listener) -> void:
	if not listener.is_active():
		listener._invalidate()
		return
	if not _modules.has(listener._module):
		_modules[listener._module] = {}
	var types: Dictionary = _modules[listener._module]
	if not types.has(listener._type):
		types[listener._type] = []
	var handlers: Array = types[listener._type]
	handlers.append(listener)
	handlers.sort_custom(_precedes)


func _get_handlers(module_name: StringName, event_type: StringName) -> Array:
	if not _modules.has(module_name):
		return []
	return _modules[module_name].get(event_type, [])


func _all_listeners() -> Array[Listener]:
	var result: Array[Listener] = []
	for types: Dictionary in _modules.values():
		for handlers: Array in types.values():
			for listener: Listener in handlers:
				result.append(listener)
	result.append_array(_pending)
	return result


func _clear_matching(kind: StringName, value: Variant = null, event_type: StringName = &"") -> int:
	var cancelled := 0
	for listener in _all_listeners():
		var matches := false
		match kind:
			&"all":
				matches = true
			&"module":
				matches = listener._module == value
			&"event":
				matches = listener._module == value and listener._type == event_type
		if matches:
			if listener.is_active():
				cancelled += 1
			listener._invalidate()
	if _dispatch_stack.is_empty():
		prune_invalid_listeners()
	return cancelled


func _compact() -> void:
	for module_name in _modules.keys():
		var types: Dictionary = _modules[module_name]
		for event_type in types.keys():
			var handlers: Array = types[event_type]
			for index in range(handlers.size() - 1, -1, -1):
				var listener: Listener = handlers[index]
				if not listener.is_active():
					listener._invalidate()
					handlers.remove_at(index)
			if handlers.is_empty():
				types.erase(event_type)
		if types.is_empty():
			_modules.erase(module_name)
	for index in range(_pending.size() - 1, -1, -1):
		if not _pending[index].is_active():
			_pending[index]._invalidate()
			_pending.remove_at(index)


func _precedes(left: Listener, right: Listener) -> bool:
	if left._priority == right._priority:
		return left._sequence < right._sequence
	return left._priority < right._priority
