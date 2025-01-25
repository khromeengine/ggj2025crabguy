extends Node2D
class_name LevelBase

@export var id: int
@export var exits: Array[LevelExit]


func _ready():
	for i in range(exits.size()):
		exits[i].exit_id = i
	LevelManager.entered_new_level.connect(_on_entered_new_level)
	
	
func _on_entered_new_level(level: int, _exit: int):
	if self.id == level:
		LevelManager.set_new_level(self)
		for exit in exits:
			exit.set_deferred("monitoring", true)
	else:
		for exit in exits:
			exit.set_deferred("monitoring", false)
