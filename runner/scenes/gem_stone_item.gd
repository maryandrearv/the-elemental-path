extends Area2D
class_name GemStoneItem

# gem disappears when Echo picks it up
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Echo":
		queue_free()
		print("gem picked up")
