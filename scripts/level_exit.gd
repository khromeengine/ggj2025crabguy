extends Area2D
class_name LevelExit

@export var goto_level: int
@export var goto_exit: int

var exit_id: int

func _ready():
	pass

func _on_area_entered(area: Area2D):
	LevelManager.entered_new_level.emit(goto_level, goto_exit)
	
