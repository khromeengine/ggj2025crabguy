extends Node

signal entered_new_level(level: int, exit: int)

var current_level: LevelBase
var loaded_levels: Dictionary
var current_exits: Array[LevelExit]


func _ready() -> void:
	entered_new_level.connect(_on_entered_new_level)


func set_new_level(level: LevelBase) -> void:
	current_level = level
	current_exits = level.exits
	
	level.unload_count = level.MAX_UNLOAD_COUNT
	
	for exit in current_exits:
		load_level(exit.goto_level)
		
	activate_level(level)
	
	for key in loaded_levels.keys():
		if level.id != loaded_levels[key].id:
			tick_level(loaded_levels[key].id)
	
		
func tick_level(id: int) -> void:
	if loaded_levels.has(id):
		var level = loaded_levels[id] as LevelBase
		level.unload_count -= 1
		if level.unload_count == 0:
			level.die()
			loaded_levels.erase(id)
			
	

func get_level(id: int) -> LevelBase:
	load_level(id)
	return loaded_levels[id]


func load_level(id: int) -> void:
	if not loaded_levels.has(id):
		var level = load(str("res://scenes/levels/level_", id, ".tscn")).instantiate()
		loaded_levels[id] = level


func activate_level(level: LevelBase) -> void:
	if not level.active:
		call_deferred("add_child", level)
		level.set_deferred("active", true)
		GameStateManager.set_respawn_point.emit(level.default_respawn)


func get_exit(id: int) -> LevelExit:
	if id > current_exits.size():
		push_warning("Invalid exit id ", id, ". Defaulting to 0.")
		return current_exits[0]
	else:
		return current_exits[id]


func _on_entered_new_level(levelid: int, exit: int) -> void:
	var level = get_level(levelid)
	set_new_level(level)
	
