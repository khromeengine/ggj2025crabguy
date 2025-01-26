extends Control

@onready var start_button = $VBoxContainer/Start as Button
@onready var exit_button = $VBoxContainer/Exit as Button

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	
	
	
func _on_start_pressed() -> void:
	var level = LevelManager.get_level(0)
	LevelManager.set_new_level(level)
	var player = load("res://scenes/player.tscn").instantiate()
	add_sibling(player)
	GameStateManager.set_respawn_point.emit(level.default_respawn)
	player.global_position = GameStateManager.respawn_point
	queue_free()


func _on_exit_pressed() -> void:
	LevelManager.tick_level(0)
