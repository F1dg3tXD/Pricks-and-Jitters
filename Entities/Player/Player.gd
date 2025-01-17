extends CharacterBody3D

@onready var skeleton_ik_head: SkeletonIK3D = $Detective/Armature/Skeleton3D/SkeletonIK_Head
@onready var skeleton_ik_look_at: SkeletonIK3D = $Detective/Armature/Skeleton3D/SkeletonIK_LookAt
@onready var animation_player: AnimationPlayer = $Detective/AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var look_target: Node3D = $IK_Targets/LookTarget
@onready var pitch_node: Node3D = $IK_Targets/LookTarget/PitchNode
@onready var camera_root: Node3D = $IK_Targets/LookTarget/PitchNode/cameraRoot
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

#Check if player can stand up in an enclosed space.
@onready var can_stand: RayCast3D = $colisionChecks/canStand

#Checks for climbing stairs with seperation rays ans raycasts.
@onready var can_climb_b: CollisionShape3D = $canClimbB
@onready var can_climb_l: CollisionShape3D = $canClimbL
@onready var can_climb_r: CollisionShape3D = $canClimbR
@onready var can_climb_fl: CollisionShape3D = $canClimbFL
@onready var can_climb_br: CollisionShape3D = $canClimbBR
@onready var can_climb_bl: CollisionShape3D = $canClimbBL
@onready var can_climb_fr: CollisionShape3D = $canClimbFR

# Movement and look variables
var speed: float = 5.0
var sprint_multiplier: float = 2.0
var crouch_speed: float = 2.5
var gravity: float = ProjectSettings.get("physics/3d/default_gravity")
var jump_velocity: float = 10.0
var look_sensitivity: float = 0.2
var movement_acceleration: float = 10.0

# Input and state variables
var movement_velocity: Vector3 = Vector3.ZERO
var target_velocity: Vector3 = Vector3.ZERO
var input_direction: Vector3 = Vector3.ZERO
var is_sprinting: bool = false
var is_crouching: bool = false

# Crouching properties
var collider_target_height: float = 2.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  # Lock mouse cursor
	skeleton_ik_head.target_node = look_target.get_path()
	skeleton_ik_look_at.target_node = camera_root.get_path()
	skeleton_ik_head.start()
	skeleton_ik_look_at.start()

func _input(event):
	if event is InputEventMouseMotion:
		rotate_look_target(-event.relative.x * 0.001)
		rotate_pitch_node(-event.relative.y * 0.001)
		#Me gustan los hombres -Dino

func _process(delta: float):
	process_input()
	update_animation_tree()
	update_collider_height(delta)

func _physics_process(delta: float):
	apply_gravity(delta)
	apply_movement(delta)
	apply_jumping()

func process_input():
	input_direction = Vector3.ZERO

	# Movement inputs
	if Input.is_action_pressed("move_forward"):
		input_direction.z -= 1
	if Input.is_action_pressed("move_backward"):
		input_direction.z += 1
	if Input.is_action_pressed("move_left"):
		input_direction.x -= 1
	if Input.is_action_pressed("move_right"):
		input_direction.x += 1

	# Sprint and crouch
	is_sprinting = Input.is_action_pressed("sprint") and not is_crouching
	is_crouching = Input.is_action_pressed("crouch")

	# Update collider height for crouching
	collider_target_height = 1.0 if is_crouching else 2.0

func rotate_look_target(delta_x: float):
	# Rotate LookTarget node horizontally (yaw)
	look_target.rotate_y(delta_x)

func rotate_pitch_node(delta_y: float):
	# Rotate PitchNode node vertically (pitch)
	var vertical_rotation = pitch_node.rotation_degrees.x + delta_y
	vertical_rotation = clamp(vertical_rotation, -90, 90)  # Prevent flipping
	pitch_node.rotation_degrees.x = vertical_rotation

func apply_gravity(delta: float):
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0  # Reset vertical velocity when grounded

func apply_movement(delta: float):
	# Calculate target speed
	var move_speed = speed
	if is_sprinting:
		move_speed *= sprint_multiplier
	elif is_crouching:
		move_speed = crouch_speed

	# Transform input direction to align with LookTarget
	var direction = look_target.transform.basis * input_direction.normalized()
	target_velocity = direction * move_speed

	# Apply acceleration and deceleration
	velocity.x = lerp(velocity.x, target_velocity.x, movement_acceleration * delta)
	velocity.z = lerp(velocity.z, target_velocity.z, movement_acceleration * delta)

	# Move the character
	move_and_slide()

	#this bitch don't fuckin work
func apply_jumping():
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_crouching:
		velocity.y = jump_velocity

func update_collider_height(delta: float):
	# Smoothly adjust the collider's height for crouching
	var current_height = collision_shape_3d.shape.height
	collision_shape_3d.shape.height = lerp(current_height, collider_target_height, movement_acceleration * delta)

func update_animation_tree():
	animation_tree.set("parameters/move/blend_position", Vector2(input_direction.x, input_direction.z))
	animation_tree.set("parameters/speed", is_sprinting)

	if is_crouching:
		animation_tree.set("parameters/state", "crouch")
	elif is_sprinting:
		animation_tree.set("parameters/state", "sprint")
	else:
		animation_tree.set("parameters/state", "walk")

# Add the updated function for climbing stairs
func _rotate_step_up_seperation_ray():
	# Calculate the direction of the player's movement in the XZ plane
	var xz_vel = velocity * Vector3(1, 0, 1)
	
	# Position the forward climbing check
	var xz_f_ray_pos = xz_vel.normalized() * can_climb_b.global_transform.basis.z.length()
	can_climb_b.global_position = global_position + xz_f_ray_pos

	# Position the left climbing check
	xz_f_ray_pos = xz_f_ray_pos.rotated(Vector3.UP, deg_to_rad(-50))
	can_climb_l.global_position = global_position + xz_f_ray_pos

	# Position the right climbing check
	xz_f_ray_pos = xz_f_ray_pos.rotated(Vector3.UP, deg_to_rad(100))
	can_climb_r.global_position = global_position + xz_f_ray_pos

	# Update the collision shapes
	can_climb_b.shape_update()
	can_climb_l.shape_update()
	can_climb_r.shape_update()

	# Check raycast collisions and steepness
	var max_slope_ang_dot = Vector3(0, 1, 0).rotated(Vector3(1, 0, 0), deg_to_rad(floor_max_angle)).dot(Vector3(0, 1, 0))
	var any_too_steep = false

	if can_climb_b.get_node("RayCast3D").is_colliding():
		if can_climb_b.get_node("RayCast3D").get_collision_normal().dot(Vector3.UP) < max_slope_ang_dot:
			any_too_steep = true
	if can_climb_l.get_node("RayCast3D").is_colliding():
		if can_climb_l.get_node("RayCast3D").get_collision_normal().dot(Vector3.UP) < max_slope_ang_dot:
			any_too_steep = true
	if can_climb_r.get_node("RayCast3D").is_colliding():
		if can_climb_r.get_node("RayCast3D").get_collision_normal().dot(Vector3.UP) < max_slope_ang_dot:
			any_too_steep = true

	# Disable the raycasts if the slope is too steep
	can_climb_b.get_node("RayCast3D").enabled = not any_too_steep
	can_climb_l.get_node("RayCast3D").enabled = not any_too_steep
	can_climb_r.get_node("RayCast3D").enabled = not any_too_steep
