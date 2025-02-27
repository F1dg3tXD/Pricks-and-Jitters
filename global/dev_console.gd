extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Console.add_command("nolcip", noclip)
	
func noclip():
	Console.print_line("Just Pretend you're hacking lol.")
