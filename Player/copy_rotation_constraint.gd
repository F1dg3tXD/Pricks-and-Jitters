extends Node3D

@export var target_node_path: NodePath

func _process(delta):
	if not target_node_path:
		return
	
	var target_node = get_node_or_null(target_node_path)
	if target_node:
		rotation_degrees = target_node.rotation_degrees
