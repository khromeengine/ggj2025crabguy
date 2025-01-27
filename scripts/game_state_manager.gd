extends Node

signal set_respawn_point(respawn_point: Node2D)
signal enter_exit(entrance_position: Node2D, exit_id: Node2D)
signal reload_level
signal deded
signal start_game
signal end_game

var player: Player
var respawn_point: Vector2 = Vector2.ZERO


func _ready():
	set_respawn_point.connect(_on_set_respawn_point)
	reload_level.connect(_on_reload_level)
	enter_exit.connect(_on_enter_exit)
	
	
func _on_set_respawn_point(obj: Node2D):
	respawn_point = obj.global_position


func _on_reload_level():
	player.global_position = respawn_point


func _on_enter_exit(entrance, exit_id):
	var offset = player.global_position - entrance
	var new_exit = LevelManager.get_exit(exit_id)
	player.global_position = new_exit.global_position + offset
	new_exit.active = false
	
