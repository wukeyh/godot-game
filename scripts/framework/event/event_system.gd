class_name EventSystem
extends RefCounted
# Source: script/core/event/event_system_ns.lua (process entry point)

const Dispatcher = preload("res://scripts/framework/event/event_dispatcher.gd")

static var _instance: EventSystem

var _dispatcher := Dispatcher.new()

var dispatcher: Dispatcher:
	get:
		return _dispatcher
	set(_value):
		push_error("EventSystem.dispatcher is read-only")


static func get_instance() -> EventSystem:
	if _instance == null:
		_instance = EventSystem.new()
	return _instance
