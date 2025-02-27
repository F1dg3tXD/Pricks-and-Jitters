extends CharacterBody3D
class_name Player

@export_subgroup("Movement")
@export var speed = 4.0
@export var accel = 8.0
@export var jump = 4.0
@export var sprint_speed = 6.0
@export var sprint_accel = 10.0

@export_subgroup("Crouching")
@export var crouch_speed = 4.0
@export var stand_height = 1.8
@export var stand_radius = 0.4
@export var crouch_height = 0.9
@export var crouch_radius = 0.3
@export var crouch_transition = 8.0

@export_subgroup("Camera")
@export var sensitivity = 0.2
@export var min_angle = -80
@export var max_angle = 90

@export_subgroup("Health")
@export var fall_damage_threshold = 20
@export var fall_damage_multiplier = 1

@onready var head = $Head
@onready var collision_shape = $CollisionShape3D
@onready var top_cast = $TopCast
@onready var ui = $UI

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var look_rot : Vector2
var moving : bool = true

func _ready():
	look_rot.y = rotation_degrees.y
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	collision_shape.shape.height = stand_height
	collision_shape.shape.radius = stand_radius
	head.transform.origin.y = stand_height - 0.2

func _physics_process(delta):
	var move_speed = speed
	var move_accel = accel
	
	if is_sprinting():
		move_speed = sprint_speed
		move_accel = sprint_accel

	if not is_on_floor():
		velocity.y -= gravity * delta
	elif moving:
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump
		elif Input.is_action_pressed("crouch") or top_cast.is_colliding():
			move_speed = crouch_speed
			crouch(delta)
		else:
			crouch(delta, true)

	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction and moving:
		velocity.x = lerp(velocity.x, direction.x * move_speed, move_accel * delta)
		velocity.z = lerp(velocity.z, direction.z * move_speed, move_accel * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, move_accel * delta)
		velocity.z = lerp(velocity.z, 0.0, move_accel * delta)

	move_and_slide()

	look_rot.y += rad_to_deg(get_platform_angular_velocity().y * delta)
	head.rotation_degrees.x = look_rot.x
	rotation_degrees.y = look_rot.y

func _input(event):
	if event is InputEventMouseMotion and moving:
		look_rot.y -= event.relative.x * sensitivity
		look_rot.x -= event.relative.y * sensitivity
		look_rot.x = clamp(look_rot.x, min_angle, max_angle)

func crouch(delta : float, reverse = false):
	var target_height = crouch_height if not reverse else stand_height
	var target_radius = crouch_radius if not reverse else stand_radius
	var target_head = target_height - 0.2 if not reverse else stand_height - 0.2

	collision_shape.shape.height = lerp(collision_shape.shape.height, target_height, crouch_transition * delta)
	collision_shape.shape.radius = lerp(collision_shape.shape.radius, target_radius, crouch_transition * delta)
	collision_shape.position.y = lerp(collision_shape.position.y, target_height * 0.5, crouch_transition * delta)
	head.transform.origin.y = lerp(head.transform.origin.y, target_head, crouch_transition * delta)

func is_sprinting() -> bool:
	return Input.is_action_pressed("sprint") and is_on_floor()

func hurt(damage : float):
	ui.hurt(damage)
	if ui.health_bar.value <= 0:
		die()

func die():
	moving = false
	ui.show_gameover()
# Function to reset the height and collision radius to default values
func reset_height():
	collision_shape.shape.height = stand_height
	collision_shape.shape.radius = stand_radius
	head.transform.origin.y = stand_height - 0.2  # Adjust head position if necessary
