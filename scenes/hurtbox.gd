extends Area2D
class_name Hurtbox

signal kill_owner

func _ready():
	body_entered.connect(on_body_entered)
	
	
func on_body_entered(body: Node2D):
	kill_owner.emit()
