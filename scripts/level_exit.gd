extends Area2D
class_name LevelExit

@export var goto_level: int
@export var goto_exit: int

var exit_id: int
var active: bool = true

func _ready():
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _on_area_entered(_area: Area2D):
	if active:
		LevelManager.entered_new_level.emit(goto_level, goto_exit)
		GameStateManager.enter_exit.emit(global_position, goto_exit)
	

func _on_area_exited(_area: Area2D):
	active = true
