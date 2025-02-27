extends Area3D

@export_file("*.tscn") var to_scene : String

func _on_body_entered(body):
	if body is Player:
		# Call deferred to avoid changing scenes while processing the physics frame
		get_tree().change_scene_to_file(to_scene)
		# Reset player's height and scale after scene change
		call_deferred("_reset_player_height", body)
	
# Function to reset player's height to default values
func _reset_player_height(player: Player):
	if player:
		player.reset_height()  # Call the reset function on the player
