extends Label

@export var active: bool = false

var counter: int = 0


func _ready():
	visible = false
	counter = 0
	active = false
	GameStateManager.reload_level.connect(_on_reload)
	GameStateManager.start_game.connect(_on_start_game)
	GameStateManager.end_game.connect(_on_end_game)
	
	
func _on_reload():
	if active:
		counter += 1
		if counter == 1:
			text = "1 Reset"
		else:
			text = str(counter, " Resets")


func _on_start_game():
	counter = 0
	visible = true
	active = true
	text = str(counter, " Resets")


func _on_end_game():
	active = false
