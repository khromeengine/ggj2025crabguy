extends Node2D
class_name LevelBase

@export var id: int
@export var exits: Array[LevelExit]
@export var default_respawn: Node2D = self


func _ready():
	for i in range(exits.size()):
		exits[i].exit_id = i
	LevelManager.entered_new_level.connect(_on_entered_new_level)
	
	
func _on_entered_new_level(level: int, _exit: int):
	var correct: bool = self.id == level
	
	for exit in exits:
			exit.set_deferred("monitoring", correct)
			
	if correct:
		LevelManager.set_new_level(self)
		GameStateManager.set_respawn_point.emit(default_respawn)
