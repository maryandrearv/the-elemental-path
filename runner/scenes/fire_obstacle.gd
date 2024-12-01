extends StaticBody2D

@onready var hitbox: Area2D = $fireobs_hitbox

# Called when the node enters the scene tree for the first time.
func _ready():
	#Add fire obstacle to fire group since this will react differently than the others
	add_to_group("fire_obs")
	
	hitbox.connect("area_entered", Callable(self, "_on_fireobs_hitbox_area_entered"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_fireobs_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		area.get_parent().game_over()
		print("Fire burned player")
	
	if area.is_in_group("Water_Attack"):
		queue_free()
		print("Fire Destroyed!")
