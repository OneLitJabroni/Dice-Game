extends RigidBody3D

# Control variables
var movement_speed = 3.0
var smoothed_accel = Vector3.ZERO
var input_threshold = 0.0
var origin_position = Vector3(0, 33.752, 76.243)

# Calibration
var calibrated_gravity = Vector3.ZERO
var is_calibrated = false
var upright_threshold = 0.7


func _ready():
	global_transform.origin = origin_position
	rotation = Vector3.ZERO
	freeze = false
	gravity_scale = 0
	call_deferred("wait_for_upright")


func wait_for_upright():
	while true:
		var gravity = Input.get_gravity().normalized()
		if gravity.length() > 0.1 and abs(gravity.y) > upright_threshold:
			calibrated_gravity = gravity
			is_calibrated = true
			print("Calibrated with gravity: ", calibrated_gravity)
			break
		await get_tree().create_timer(0.1).timeout


func _physics_process(_delta):
	# --- Accelerometer Movement ---
	var accel = Input.get_accelerometer()
	var gravity = Input.get_gravity()
	var linear_accel = accel - gravity  # remove gravity component, leaving only real movement
	smoothed_accel = smoothed_accel.lerp(linear_accel, 0.3)
	var target_position = origin_position + Vector3(
		smoothed_accel.x * movement_speed,
		smoothed_accel.y * movement_speed,
		smoothed_accel.z * movement_speed
	)

	if smoothed_accel.length() > input_threshold:
		linear_velocity = (target_position - global_position) * 5.0
	else:
		linear_velocity = (origin_position - global_position) * 5.0

	# --- Gyroscope Rotation: shortest-arc quaternion from calibrated to current gravity ---
	if not is_calibrated:
		return

	var gravity_normalized = gravity.normalized()
	if gravity.length() < 0.1:
		return

	# Rotation that takes calibrated_gravity to current gravity
	var target_quat = Quaternion(gravity_normalized, calibrated_gravity)
	# We track the cup's own accumulated rotation as a quaternion separately
	var cup_quat = Quaternion(basis.orthonormalized())
	
	# Ensure shortest-path interpolation (avoid double-cover flip)
	if cup_quat.dot(target_quat) < 0.0:
		target_quat = -target_quat
		
	# Clamp maximum rotation angle from neutral to avoid near-180 instability
	var neutral_quat = Quaternion(Basis.IDENTITY)
	var angle_from_neutral = neutral_quat.angle_to(target_quat)
	var max_angle = deg_to_rad(100)  # tune this - how far the cup can tilt before capping
	if angle_from_neutral > max_angle:
		target_quat = neutral_quat.slerp(target_quat, max_angle / angle_from_neutral)

	var new_quat = cup_quat.slerp(target_quat, 15.0 * _delta)
	basis = Basis(new_quat).orthonormalized()
