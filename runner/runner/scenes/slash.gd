extends Area2D

var slash_duration : float = 0.2
var damage : int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	
	set_process(true)
	visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
# Detection with vine
func _on_area_entered(area: Area2D):
	if area.is_in_group("vine"):
		_vine_hit(area)

func _vine_hit(vine: Area2D):
	print("Vine hit by fire slash!")
	vine.queue_free()
