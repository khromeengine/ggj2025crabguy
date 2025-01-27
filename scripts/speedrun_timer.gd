extends Label
class_name SpeedrunTimer

@export var active: bool = false

var hr: int = 0
var min: int = 0
var sec: int = 0
var ms: float = 0


func _ready():
	active = false
	visible = false
	GameStateManager.start_game.connect(_on_start_game)
	GameStateManager.end_game.connect(_on_end_game)


func _physics_process(delta):
	if active:
		ms += delta
		if ms >= 1:
			sec += 1
			ms -= 1
		if sec >= 60:
			min += 1
			sec -= 60
		if min >= 60:
			hr += 1
			min -= 60
			
		text = str(str("%02d" % hr), ":", str("%02d" % min), ":", str("%02d" % sec), ".", str("%02d" % (snappedf(ms, 0.01)*100)))


func _on_start_game():
	active = true
	visible = true
	hr = 0
	min = 0
	ms = 0
	sec = 0


func _on_end_game():
	active = false
