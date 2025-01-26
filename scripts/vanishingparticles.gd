extends GPUParticles2D
class_name VanishingParticles


func _ready() -> void:
	finished.connect(_on_done)
	

func _on_done() -> void:
	queue_free()
