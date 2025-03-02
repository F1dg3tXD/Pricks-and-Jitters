extends Node3D

var noclip_enabled: bool = false
#var debug_draw_enabled: bool = false
var mapsrc_enabled: bool = false

func _ready() -> void:
	Console.pause_enabled = true
	Console.add_command("noclip", noclip, 0, 0, "Doesn't Work Yet!")
	#Console.add_command("debug", drawdebug, 0, 0, "Toggles Debug Views")
	Console.add_command("mapsrc", mapsrc, 0, 0, "Enable loading external scenes from outside the maps folder.")
	Console.add_command("map", loadmap, ["'Scene Name'"], 1, "Loads a map or level from the maps folder.")

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
#func drawdebug():
	#debug_draw_enabled = !debug_draw_enabled
	#
	## Toggle visible debug options (same as Editor's checkboxes)
	#ProjectSettings.set("debug/shapes/collision", debug_draw_enabled)
	#ProjectSettings.set("debug/shapes/navigation", debug_draw_enabled)
	#ProjectSettings.set("debug/shapes/path", debug_draw_enabled)
	#ProjectSettings.set("debug/shapes/avoidance", debug_draw_enabled)
#
	## Apply the changes immediately
	#ProjectSettings.save()
#
	## Print status to console
	#if debug_draw_enabled:
		#Console.print_line("Debug View: ENABLED (Collision, Navigation, Paths, Avoidance)")
	#else:
		#Console.print_line("Debug View: DISABLED")

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
