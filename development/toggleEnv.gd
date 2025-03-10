extends Node3D

var playback : AnimationNodeStateMachinePlayback
var is_night := true
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var button: StaticBody3D = $"../Button"

func _ready():
	playback = animation_tree.get("parameters/playback")

func _on_button_interacted(body: Variant) -> void:
	is_night = !is_night
	
	if is_night:
		playback.travel("NightToDay")
		button.prompt_message = "Night"
	else:
		playback.travel("DayToNight")
		button.prompt_message = "Day"
