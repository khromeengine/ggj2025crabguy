extends Node2D
class_name LevelBase

const MAX_UNLOAD_COUNT := 1

@export var id: int
@export var exits: Array[LevelExit]
@export var default_respawn: Node2D = self

var active: bool = false
var unload_count: int

func _ready():
	unload_count = MAX_UNLOAD_COUNT
	for i in range(exits.size()):
		exits[i].exit_id = i
	
	
func die():
	queue_free()
	
	
