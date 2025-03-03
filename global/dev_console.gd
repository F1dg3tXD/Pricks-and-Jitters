extends Node3D

var noclip_enabled: bool = false
var debug_draw_enabled: bool = false
var mapsrc_enabled: bool = false

func _ready() -> void:
	Console.pause_enabled = true
	Console.add_command("noclip", noclip, 0, 0, "Doesn't Work Yet!")
	Console.add_command("debug", drawdebug, 0, 0, "Toggles Debug Views")
	Console.add_command("mapsrc", mapsrc, 0, 0, "Enable loading external scenes from outside the maps folder.")
	Console.add_command("map", loadmap, ["'Scene Name'"], 1, "Loads a map or level from the maps folder.")
	Console.add_command("kill", kill, 0, 0, "Kills the player.")
	Console.add_command("resetHeight", reset_height, 0, 0, "Resets Player height.")

func get_player() -> Player:
	for node in get_tree().get_nodes_in_group("player"):
		if node is Player:
			return node
	return null

# Toggles noclip mode (disables collision & gravity)
func noclip():
	var player = get_player()
	if not player:
		Console.print_line("Error: Player not found!")
		return
	
	noclip_enabled = !noclip_enabled  # Toggle noclip

	if noclip_enabled:
		player.noclip_enabled = true  # Enable noclip mode in the player script
		Console.print_line("Noclip enabled!")
		Console.print_line("This doesn't work yet!")
	else:
		player.noclip_enabled = false  # Disable noclip mode in the player script
		Console.print_line("Noclip disabled!")
		Console.print_line("This doesn't work yet!")

 # Toggles debug visualization settings
func drawdebug():
	debug_draw_enabled = !debug_draw_enabled
	
	var root = get_tree().current_scene
	if root:
		toggle_debug_shapes(root)
	
	# Print status to console
	if debug_draw_enabled:
		Console.print_line("Debug View: ENABLED (Collision, Navigation, Paths, Avoidance)")
	else:
		Console.print_line("Debug View: DISABLED")

func toggle_debug_shapes(node):
	for child in node.get_children():
		if child.has_node("debugShape"):
			var debug_shape = child.get_node("debugShape")
			if debug_shape is Node3D:
				debug_shape.visible = debug_draw_enabled
		toggle_debug_shapes(child)  # Recursively check all children

func enable_all_debug_shapes():
	var root = get_tree().current_scene
	if root:
		toggle_debug_shapes(root)

func mapsrc():
	mapsrc_enabled = !mapsrc_enabled
	
	if mapsrc_enabled:
		Console.print_line("Developer Maps Enabled! (This might break things!!)")
	else:
		Console.print_line("Developer Maps Disabled!")
	 
# Loads a map from the "maps" folder
func loadmap(scene_name: String):
	if mapsrc_enabled:
		var scene_path = "res://" + scene_name + ".tscn"
		if ResourceLoader.exists(scene_path):
			Console.print_line("Loading map: " + scene_name)
			var tree = get_tree()
			tree.change_scene_to_file(scene_path)
		else:
			Console.print_line("Error: Map '" + scene_name + "' not found!")
	else:
		var scene_path = "res://maps/" + scene_name + ".tscn"
		if ResourceLoader.exists(scene_path):
			Console.print_line("Loading map: " + scene_name)
			var tree = get_tree()
			tree.change_scene_to_file(scene_path)
		else:
			Console.print_line("Error: Map '" + scene_name + "' not found!")
			
func kill():
	var player = get_player()
	player.die()

func reset_height():
	var player = get_player()
	player.reset_height()
