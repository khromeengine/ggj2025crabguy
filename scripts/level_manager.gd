extends Node

signal entered_new_level(level: int, exit: int)

var current_level: LevelBase
var loaded_levels: Dictionary
var current_exits: Array[LevelExit]


func set_new_level(level: LevelBase) -> void:
	current_level = level
	current_exits = level.exits
	for exit in current_exits:
		load_level(exit.goto_level)
	

func get_level(id: int) -> LevelBase:
	load_level(id)
	return loaded_levels[id]


func load_level(id: int) -> void:
	if not loaded_levels.has(id):
		var level = load(str("res://scenes/levels/level_", id)).instantiate
		loaded_levels[id] = level


func get_exit(id: int) -> LevelExit:
	if id > current_exits.size():
		push_warning("Invalid exit id ", id, ". Defaulting to 0.")
		return current_exits[0]
	else:
		return current_exits[id]
