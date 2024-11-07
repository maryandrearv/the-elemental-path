extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	self.add_to_group("Slash")
	connect("area_entered", Callable(self, "on_area_entered"))
	
	set_process(true)
	visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
# Detection with vine
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("vine"):
		print("Slash hit vine")
		area.destroy_vine()
		queue_free()
