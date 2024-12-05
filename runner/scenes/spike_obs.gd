extends StaticBody2D

@onready var hitbox: Area2D = $SpikeHitbox
@onready var hitbox2: Area2D = $SpikeHitbox2
# Called when the node enters the scene tree for the first time.
func _ready():
	#Add fire obstacle to fire group since this will react differently than the others
	hitbox.connect("area_entered", Callable(self, "_on_spikeobs_hitbox_area_entered"))
	hitbox2.connect("area_entered", Callable(self, "_on_spikeobs_hitbox_area_entered"))
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_spikeobs_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		area.get_parent().game_over()
		print("Spikes collided with player")
	
