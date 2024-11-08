extends Area2D

var is_destroyed : bool = false
signal vine_collided

# Called when the node enters the scene tree for the first time.
func _ready():
	self.add_to_group("vine")
	connect("body_entered", Callable(self, "_on_body_entered"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func destroy_vine():
	if not is_destroyed:
		is_destroyed = true
		#Remove Vine from scene
		queue_free()
		print("Vine Destroyed!")
