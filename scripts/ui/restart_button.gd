extends Button

func _ready():
	pressed.connect(_on_pressed)
	

func _on_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")
