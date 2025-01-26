extends Node

signal set_respawn_point(respawn_point: Node2D)
signal enter_exit(entrance_position: Node2D, exit_id: Node2D)
signal reload_level

var player: Player
var respawn_point: Vector2 = Vector2.ZERO


func _ready():
	set_respawn_point.connect(_on_set_respawn_point)
	reload_level.connect(_on_reload_level)
	
	
func _on_set_respawn_point(obj: Node2D):
	respawn_point = obj.global_position


func _on_reload_level():
	player.global_position = respawn_point


func _on_enter_exit(entrance, exit_id):
	var offset = player.global_position - entrance
	player.global_position = LevelManager.get_exit(exit_id).global_position + offset
