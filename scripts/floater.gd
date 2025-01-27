extends Node2D
class_name Floater

@export var speed: float = 1


func _ready():
	$Sprite2D/AnimationPlayer.speed_scale = speed
	$Sprite2D/AnimationPlayer.play("float")
