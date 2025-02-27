extends Node3D  # Assuming PlayerStart is a Node3D or derived class

@export var player_scene : PackedScene  # Export variable to hold the Player scene

var player_instance : Node3D = null  # Store the player instance

func _ready():
	# Remove any existing player node in the scene (if any)
	if player_instance != null:
		player_instance.queue_free()

	# Instantiate the player scene
	player_instance = player_scene.instantiate()

	if player_instance:
		# Defer the addition of the player to the scene
		call_deferred("add_player_to_scene", player_instance)
	else:
		push_error("[PlayerStart] Player scene failed to instantiate!")

func add_player_to_scene(player: Node3D):
	# Add the player to the current scene after the frame has finished
	get_tree().current_scene.add_child(player)

	# Teleport the player to the PlayerStart's position
	player.global_transform = global_transform
	print("[PlayerStart] Player teleported to PlayerStart location.")
