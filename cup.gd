extends RigidBody3D

@onready var lid = $Lid
var launch_force = 15.0
var pour_triggered = false

@export var movement_speed: float = 1.05
@export var input_threshold: float = 0.25        # minimum movement speed to respond to
@export var origin_position: Vector3 = Vector3(0, 33.752, 76.243)

@export_group("Sensor Calibration")
@export var invert_x_axis: bool = true
@export var invert_y_axis: bool = false
@export var invert_z_axis: bool = true


var smoothed_accel = Vector3.ZERO
var smoothed_gravity = Vector3.DOWN
var previous_position = Vector3.ZERO


func _ready():
	global_position = origin_position
	basis = Basis.IDENTITY
	freeze = false
	previous_position = global_position


func _physics_process(delta):
	var accel = Input.get_accelerometer()
	var gravity = Input.get_gravity()
	
	# Apply axis inversions based on your Inspector checkboxes
	var calibrated_gravity = Vector3(
		-gravity.x if invert_x_axis else gravity.x,
		gravity.y if invert_y_axis else gravity.y,
		-gravity.z if invert_z_axis else gravity.z
	)
	
	var calibrated_accel = Vector3(
		-accel.x if invert_x_axis else accel.x,
		accel.y if invert_y_axis else accel.y,
		-accel.z if invert_z_axis else accel.z
	)

	# --- Movement (Your Original Preferred Logic) ---
	var linear_accel = calibrated_accel - calibrated_gravity

	smoothed_accel = smoothed_accel.lerp(linear_accel, 0.15)


	if smoothed_accel.length() > input_threshold:
		var target_position = origin_position + Vector3(
			-smoothed_accel.x * movement_speed,
			smoothed_accel.y * movement_speed,
			-smoothed_accel.z * movement_speed
		)
		
		transform.origin = transform.origin.lerp(target_position, 5.0 * delta)
	else:
		transform.origin = transform.origin.lerp(origin_position, 5.0 * delta)
		
	print("gravity.y: ", calibrated_gravity.y, " gravity.z: ", calibrated_gravity.z, " accel.y: ", smoothed_accel.y, " accel.z: ", smoothed_accel.z)

	# --- Rotation (Your Perfect Tilt Logic) ---
	if calibrated_gravity.length_squared() > 0.1:
		smoothed_gravity = smoothed_gravity.lerp(calibrated_gravity.normalized(), 10.0 * delta)
		
		var target_up = -smoothed_gravity
		
		if target_up.is_equal_approx(Vector3.DOWN):
			target_up = Vector3.DOWN + Vector3(0.001, 0, 0)
			
		var target_quat = Quaternion(Vector3.UP, target_up)
		var current_quat = Quaternion(basis.orthonormalized())
		basis = Basis(current_quat.slerp(target_quat, 12.0 * delta))
		


# --- Detect forward push gesture using raw smoothed acceleration ---
	var is_pushing_forward = smoothed_accel.z < -3.0  # tune sign/threshold based on testing

	print("smoothed_accel.z: ", smoothed_accel.z, " is_pushing: ", is_pushing_forward, " triggered: ", pour_triggered)

	if is_pushing_forward and not pour_triggered:
		pour_triggered = true
		lid.disabled = true
		launch_dice()
		
		
		
func launch_dice():
	var all_dice = get_tree().get_nodes_in_group("dice_group")
	for die in all_dice:
		if die.global_position.distance_to(global_position) < 6.0:
			var forward_dir = -global_transform.basis.z
			var up_dir = Vector3.UP
			var launch_dir = (forward_dir * 2 + up_dir * 0.6).normalized()
			die.apply_central_impulse(launch_dir * launch_force)
			var random_torque = Vector3(randf_range(-5, 5), randf_range(-5, 5), randf_range(-5, 5))
			die.apply_torque_impulse(random_torque)

	await get_tree().create_timer(1.0).timeout
	lid.disabled = false
	pour_triggered = false
