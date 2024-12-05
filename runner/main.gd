extends Node2D
@onready var fire_animation: AnimatedSprite2D = $Fire
@onready var vine_area: StaticBody2D = $Vine

@onready var bg_music = $"/root/BackgroundMusic"
@onready var game_over_sound = $GameOverSound

# preload obstacle scenes
var rock_scene = preload("res://scenes/rock.tscn")
var platform_scene = preload("res://scenes/platform.tscn")
@onready var vine_scene = preload("res://scenes/vine.tscn")
@onready var slash_scene = preload("res://scenes/slash.tscn")
@onready var spike_scene = preload("res://scenes/spike_obs.tscn")
@onready var fire_scene = preload("res://scenes/fire_obstacle.tscn")
@onready var gemstone_scene = preload("res://scenes/gem_stone_item.tscn")
@onready var rock_pillar_scene = preload("res://scenes/rock_pillar.tscn")
@onready var rock_pillar_tandb_scene = preload("res://scenes/rock_pillar_t_and_b.tscn")


#var obstacle_types := [rock_scene,rock_scene,rock_scene]
#var obstacles : Array = []
# Obstacle Variables
var last_obs
var top_rocks : Array = []
#var bottom_spikes : Array = []
var obstacles = Global.obstacles

# Game component variables
const ECHO_START_POS := Vector2(150, 485)
const CAM_START_POS := Vector2(576, 324)
var screen_size : Vector2
var ground_height : int
var ceiling_height : int
var game_running : bool

#Fire Slash components
const FIRESLASH_OFFSET = Vector2(100,0)

#obstacle detection vars
@onready var player_position: Node2D = $Echo
@onready var top_rock : RigidBody2D

# score variables
var score : int
var SCORE_MODIFIER : int = 10
var high_score: int

# Physics variables
var speed : float
const START_SPEED : float = 8.0
const MAX_SPEED : int = 15
const SPEED_MODIFIER : int = 12000
var push_distance: float = 800.0 


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	ceiling_height = $Ceiling.get_node("Sprite2D").texture.get_height()
	$GameOver.get_node("Button").pressed.connect(new_game)
	new_game()
func new_game():
	
	
	#Start Game in paused state and allows user to press space to start
	get_tree().paused = false
	score = 0
	show_score()
	game_running = false
	
	# Clear obstacles array to start a new game with fresh obstacles
	for obs in obstacles:
		if is_instance_valid(obs):
			obs.queue_free()
	obstacles.clear()
	
	# Find position of each node
	$Echo.position = ECHO_START_POS 
	$Echo.velocity = Vector2(0,0)
	$Camera2D.position = CAM_START_POS
	$Ground.position = Vector2(127,-623)
	$Ceiling.position = Vector2(129,-1237)
	$Background.scroll_offset = Vector2(0,0)
	
	# Hide User Interface nodes and show instructions and return button
	$HUD.get_node("StartLabel").show()
	$HUD.get_node("Return").show()
	$GameOver.get_node("ScoreTitle").hide()
	$GameOver.get_node("ScoreCount").hide()
	$GameOver.get_node("Button").hide()
	
	
	last_obs = null # Reset last_obs
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

# If game is running, calculate speed based on where you are at with the score.
	if game_running:
		speed = START_SPEED + score / SPEED_MODIFIER
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		#Generate obstacles when game is proccessing
		generate_obs()
		
		# Calculates the camera and player position to match the speed
		$Echo.position.x += speed
		$Camera2D.position.x += speed

		# starts gem spawner
		$GemSpawnTimer.start()
		
		# update score
		score += speed
		show_score()
		# repeat backgrounds
		if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
			$Ground.position.x += screen_size.x 
		if $Camera2D.position.x - $Ceiling.position.x > screen_size.x * 1.5:
			$Ceiling.position.x += screen_size.x 
		if $Camera2D.position.x - $Background.scroll_offset.x > screen_size.x * 1.5:
			$Background.scroll_offset.x += screen_size.x
		
		 
	else:
		if Input.is_action_just_pressed("ui_accept"):
			game_running = true
			$HUD.get_node("StartLabel").hide()
			$HUD.get_node("Return").hide()

		
	#knock over situation
	if Input.is_action_just_pressed("earth"):
		knock_over_rock()
		# Debug: Print positions of the player and the boulder
		print("Player Position:", player_position.global_position)
	
	game_over()

# game over function that pauses game, shows scores, and allows you to restart
func game_over():
	
	check_high_score()
	#reset hud and gameover screen
	# Calculate the visible area based on the camera position
	var camera_left_boundary = $Camera2D.position.x - screen_size.x / 2
	var camera_right_boundary = $Camera2D.position.x + screen_size.x / 2

	# Check if the Echo is out of the visible area
	if $Echo.position.x < camera_left_boundary or $Echo.position.x > camera_right_boundary:
		get_tree().paused = true  # Pause the game
		if get_tree().paused == true:
			$GameOver.get_node("Button").show()
			$GameOver.get_node("ScoreTitle").show()
			$GameOver.get_node("ScoreCount").show()
			$GameOver.get_node("ScoreCount").text = str(score / SCORE_MODIFIER)
			game_over_sound.play()
			print("game over")
	
func generate_obs():
	#clean up invalid obstacles
	obstacles = obstacles.filter(is_instance_valid)
	
	# Ensure to generate rocks at appropriate intervals
	if last_obs == null or (is_instance_valid(last_obs) and last_obs.position.x < score + randi_range(300, 500)):
		var obstacle_type = randi_range(0, 5)
		
		var obs
		var obs_x : int = $Camera2D.position.x + screen_size.x + randi_range(200, 400)
		
		if obstacle_type == 0:
			var pillar = rock_pillar_scene.instantiate()
			var obs_y = ground_height
			pillar.position = Vector2(obs_x, obs_y)
			add_child(pillar)
			obstacles.append(pillar)
			
			var spikes = rock_pillar_tandb_scene.instantiate()
			spikes.position = Vector2(obs_x, obs_y)
			add_child(spikes)
			obstacles.append(spikes)
			
			last_obs = pillar
		
		else:
			if obstacle_type == 1: #Rock
				obs = rock_scene.instantiate()
				var obs_height = obs.get_node("Sprite2D").texture.get_height()
				var obs_scale = obs.get_node("Sprite2D").scale
				var obs_y : int = screen_size.y - ground_height - obs_height
			
				#Set up rock obstacle
				add_obs(obs, obs_x, obs_y)
			
				#Add top rock to array if it has one
				var top_rock = obs.get_node("TopRock")  # Assuming your top rock is named "TopRock"
				if top_rock:
					top_rocks.append(top_rock)
		
			elif obstacle_type == 2: #Vine
				obs = vine_scene.instantiate()
				obs.add_to_group("vine")
				add_child(obs)
				var obs_height = obs.get_node("Sprite2D").texture.get_height()
				var obs_y : int = ceiling_height #position near ceiling
			
				add_obs(obs, obs_x, obs_y)
			
			elif obstacle_type == 3: #Platform
				obs = platform_scene.instantiate()
				var obs_height = obs.get_node("Sprite2D").texture.get_height()
				var obs_scale = obs.get_node("Sprite2D").scale
				var obs_y : int = (screen_size.y - ground_height - ceiling_height) / 1.83 - obs_height / 3
			
				add_obs(obs, obs_x, obs_y)
		
			elif obstacle_type == 4: #Spikes
				obs = spike_scene.instantiate()
				var obs_height = obs.get_node("Stalagmites").texture.get_height()
				var obs_scale = obs.get_node("Stalactites").scale
				var obs_y : int = ground_height
			
				add_obs(obs, obs_x, obs_y)
		
			elif obstacle_type == 5: #flames/fire obstacle
				obs = fire_scene.instantiate()
				obs.get_node("FireObstacle").play()
				#hardcoded y-location, will have to readjust after sprite change
				var obs_y : int = 294
			
				add_obs(obs, obs_x, obs_y)		

			last_obs = obs
		

func add_obs(obs, x, y):
		obs.position = Vector2(x, y)
		add_child(obs)
		obstacles.append(obs)
		

func is_near_rock(rock: RigidBody2D) -> bool:
	var distance_to_rock = player_position.global_position.distance_to(rock.global_position)
	print("Distance to boulder:", distance_to_rock)  # Debugging output
	print("Player Position:", player_position.global_position)  # Debugging output
	print("Rock Position:", rock.global_position)  # Debugging output
	return distance_to_rock <= push_distance

func show_score():
	$HUD.get_node("ScoreLayer").text = "SCORE: " + str(score / SCORE_MODIFIER)

func check_high_score():
	if score > high_score:
		high_score = score
		$HUD.get_node("HighScoreLabel").text = "HIGH SCORE: " + str(high_score/SCORE_MODIFIER) 

# Need to ask tutorial leader how to seperate different skills into different files to eliminate confusing long code
func knock_over_rock():
	#remove invalid object
	obstacles = obstacles.filter(is_instance_valid)
	
	var is_rock_hit: bool = false
	
	var nearest_rock: RigidBody2D = null
	var closest_distance: float = push_distance  # Start with the maximum push distance

	for rock in obstacles:
		if rock is RigidBody2D and is_near_rock(rock):
			var distance_to_rock = player_position.global_position.distance_to(rock.global_position)
			# Ensure the rock is in front of the player
			if distance_to_rock < closest_distance and rock.global_position.x > player_position.global_position.x:
				closest_distance = distance_to_rock
				#is_rock_hit = true
				nearest_rock = rock  # Store the closest rock
			#else:
				#is_rock_hit = false

	if nearest_rock: #and not is_rock_hit
		# Move the nearest rock slightly (adjust the values as needed)
		var offset = Vector2(200, 0)  # Move the rock slightly to the right
		nearest_rock.position += offset  # Change position directly
		
		# Move the top rock sprite (assuming it's a direct child of the same RigidBody2D)
		var top_rock_sprite = nearest_rock.get_node("TopRock")  # Change "Sprite2D" to your top rock sprite's name
		if top_rock_sprite:
			top_rock_sprite.position += offset  # Move the top rock sprite

		# Move the collision shape (make sure it exists)
		var collision_shape = nearest_rock.get_node("CollisionShape2D")  # Assuming your collision shape is named "CollisionShape2D"
		if collision_shape:
			collision_shape.position += offset  # Move the collision shape along with the top rock
	else:
		print("No nearby rock to knock over.")

# spawns gems at random positions at a 5 second interval
func _on_gem_spawn_timer_timeout() -> void:
	# NOTE: code only works once you restart the game after dying once
	#		problem with line 290
	
	# var gem = gemstone_scene.instantiate()
	# var gem_location = $GemSpawnPath/GemSpawnPathFollow
	# gem_location.progress_ratio = randf()
	# gem.position = gem_location
	# add_child(gem)
	
	print("gem spawned")
