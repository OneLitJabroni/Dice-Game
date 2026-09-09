extends RigidBody3D

@export var spawn_position: Vector3

@onready var lid = $Lid
var launch_force = 100.0
var pour_triggered = false

@export var movement_speed: float = 1.05
@export var input_threshold: float = 0.25        # minimum movement speed to respond to
@export var origin_position: Vector3

@export_group("Sensor Calibration")
@export var invert_x_axis: bool = true
@export var invert_y_axis: bool = false
@export var invert_z_axis: bool = true

var last_printed_values = Vector3.ZERO
var last_printed_smoothed_z = 0.0

var smoothed_accel = Vector3.ZERO
var smoothed_gravity = Vector3.DOWN
var previous_position = Vector3.ZERO


func _ready():
	if spawn_position != Vector3.ZERO:
		global_position = spawn_position
	origin_position = global_position
	print("Cup ready, origin_position captured as: ", origin_position)
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
		


	# --- Rotation (Your Perfect Tilt Logic) ---
	if calibrated_gravity.length_squared() > 0.1:
		smoothed_gravity = smoothed_gravity.lerp(calibrated_gravity.normalized(), 10.0 * delta)
		
		var target_up = -smoothed_gravity
		
		if target_up.is_equal_approx(Vector3.DOWN):
			target_up = Vector3.DOWN + Vector3(0.001, 0, 0)
			
		var target_quat = Quaternion(Vector3.UP, target_up)
		var current_quat = Quaternion(basis.orthonormalized())
		basis = Basis(current_quat.slerp(target_quat, 12.0 * delta))
		
		# --- Print only when values change significantly (>= 1.0 unit) ---
		var current_gravity_check = Vector3(gravity.x, gravity.y, gravity.z)
		var gravity_change = current_gravity_check.distance_to(last_printed_values)
		var smoothed_z_change = abs(smoothed_accel.z - last_printed_smoothed_z)

		if gravity_change >= 1.0 or smoothed_z_change >= 1.0:
			last_printed_values = current_gravity_check
			last_printed_smoothed_z = smoothed_accel.z
	
# --- Detect horizontal + forward push gesture --- 
	var is_horizontal = gravity.z <= -9.0  # phone relatively flat, not tilted forward/back - tune based on testing
	var is_moving_forward = smoothed_accel.z >= 1 # deliberate forward push - tune based on testing

	if is_horizontal and is_moving_forward and not pour_triggered:
		pour_triggered = true
		lid.disabled = true
		launch_dice()
		
		
func launch_dice():
	var all_dice = get_tree().get_nodes_in_group("dice_group")

	for die in all_dice:
		die.freeze = false
		if die.global_position.distance_to(global_position) < 15.0:
			var forward_dir = -global_transform.basis.z.normalized()
			var up_dir = Vector3.UP
			var launch_dir = (forward_dir * 0.9 + up_dir * 0.6).normalized()
			die.linear_velocity = launch_dir * launch_force
			
	await get_tree().create_timer(1.0).timeout
	lid.disabled = false
	pour_triggered = false
