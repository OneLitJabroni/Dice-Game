extends RigidBody3D  # The cup remains a RigidBody3D

# Control variables
var movement_speed = 2.0  # Speed of accelerometer-based movement

var smoothed_accel = Vector3.ZERO  # Low-pass filter for accelerometer data

var k: float = 0.98  # Smoothing factor for gyroscope integration

# Set origin position (where the cup stays)
var origin_position = Vector3(-69, 34, 0)

# Threshold to determine when the accelerometer input is considered "stopped"
var input_threshold = 0.1

func _ready():
	# Ensure the cup starts at the origin position
	global_transform.origin = origin_position

func _process(delta):
	# --- Get Accelerometer Data for Movement ---
	var accel = Input.get_accelerometer()
	smoothed_accel = smoothed_accel.lerp(accel, 0.3)
	
	# Correct movement (no axis inversion)
	var movement = Vector3(
		-smoothed_accel.z * movement_speed,  # Move left/right (X axis)
		smoothed_accel.y * movement_speed,  # Move up/down (Y axis)
		smoothed_accel.x * movement_speed    # Move forward/backward (Z axis)
	)
	
	# Check if the input is below the threshold
	if smoothed_accel.length() > input_threshold:
		global_transform.origin = origin_position + movement
	else:
		global_transform.origin = global_transform.origin.lerp(origin_position, 0.08)

	# --- Use Gravity Sensor for Absolute Orientation ---
	var gravity = Input.get_gravity().normalized()
	var pitch = atan2(-gravity.x, gravity.y)  # Forward/back tilt
	var roll = atan2(gravity.z, gravity.y)  # Left/right tilt

	# Apply the rotation so the cup always matches phone orientation
	rotation = Vector3(pitch, 0.0, roll)  # Yaw can be added if using a magnetometer
