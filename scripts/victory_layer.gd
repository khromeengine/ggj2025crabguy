extends CanvasLayer


func _ready():
	GameStateManager.end_game.connect(_on_end_game)
	print("sdfasdf")
	
	
func _on_end_game():
	visible = true
