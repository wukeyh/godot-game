class_name EventDefine
extends RefCounted
# Source: script/core/event/event_define.lua

enum DispatchError {
	INVALID_ARGUMENT = -1,
	REENTRANT = -2,
	DEPTH_LIMIT = -3,
}

const MAX_DISPATCH_DEPTH := 32


class Module:
	const CORE: StringName = &"core"
	const EDITOR: StringName = &"editor"
	const LEVEL: StringName = &"level"
	const GAMEPLAY: StringName = &"gameplay"
	const GUI: StringName = &"gui"


class Type:
	class Editor:
		const SELECTION_CHANGED: StringName = &"SELECTION_CHANGED"

	# Protocol names only; emitted when the corresponding Level feature is connected.
	class Level:
		const ON_LEVEL_ENTER: StringName = &"ON_LEVEL_ENTER"
		const ON_LEVEL_LEAVE: StringName = &"ON_LEVEL_LEAVE"
		const ON_LEVEL_START: StringName = &"ON_LEVEL_START"
		const ON_LEVEL_FINISH: StringName = &"ON_LEVEL_FINISH"
		const ON_LEVEL_PAUSE: StringName = &"ON_LEVEL_PAUSE"
		const ON_LEVEL_RESUME: StringName = &"ON_LEVEL_RESUME"
		const ON_LEVEL_SNAPSHOT_CREATE: StringName = &"ON_LEVEL_SNAPSHOT_CREATE"
		const ON_LEVEL_SNAPSHOT_RESET: StringName = &"ON_LEVEL_SNAPSHOT_RESET"
		const ON_LEVEL_BEGIN_SAVE: StringName = &"ON_LEVEL_BEGIN_SAVE"
		const ON_LEVEL_END_SAVE: StringName = &"ON_LEVEL_END_SAVE"
		const ON_LEVEL_BEGIN_LOAD: StringName = &"ON_LEVEL_BEGIN_LOAD"
		const ON_LEVEL_END_LOAD: StringName = &"ON_LEVEL_END_LOAD"
