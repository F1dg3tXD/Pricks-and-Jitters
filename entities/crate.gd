extends Node3D
@onready var destruction: Destruction = $Destruction

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_rigid_body_3d_interacted(body: Variant) -> void:
	destruction.destroy()
