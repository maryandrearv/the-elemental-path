extends Area2D
class_name Gem

@onready var gem_sound = $GemSound

func _ready():
	# Connect the area’s body_entered signal here
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Echo":
		gem_sound.play()  # Play the pickup sound
		queue_free()
		print("gem picked up")
