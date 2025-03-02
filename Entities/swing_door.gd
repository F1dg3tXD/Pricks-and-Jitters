extends Node3D

@onready var open: AudioStreamPlayer3D = $open
@onready var close: AudioStreamPlayer3D = $close
@onready var door_interact: Interactable = $Armature/Skeleton3D/BoneAttachment3D/StaticBody3D

var playback : AnimationNodeStateMachinePlayback
var is_open := false

func _ready():
	playback = $AnimationTree.get("parameters/playback")


func toggle(_body):
	is_open = !is_open
	
	if is_open:
		playback.travel("opening")
		open.play()
		door_interact.prompt_message = "Close"
	else:
		playback.travel("closing")
		close.play()
		door_interact.prompt_message = "Open"
