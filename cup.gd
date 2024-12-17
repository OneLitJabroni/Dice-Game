extends RigidBody3D  # The cup remains a RigidBody3D

# Control variables
var movement_speed = 1.0  # Speed of accelerometer-based movement
var smoothed_accel = Vector3.ZERO  # Low-pass filter for accelerometer data

var pitch: float = 0.0
var roll: float = 0.0
var yaw: float = 0.0

var initial_yaw : float = 0.0

var k : float = 0.98

# Set origin position (where the cup stays)
var origin_position = Vector3(-69, 34, 0)

func _ready():
	# Ensure the cup starts at the origin position
	global_transform.origin = origin_position
	var magnet: Vector3 = Input.get_magnetometer()
	print(magnet)
	initial_yaw = atan2(-magnet.x, magnet.z) 


func _process(delta):
	# --- Get Accelerometer Data for Movement ---
	var accel = Input.get_accelerometer()  # Returns a Vector3 with x, y, z values
	
	# Smooth the accelerometer data to reduce jitter
	smoothed_accel = smoothed_accel.lerp(accel, 0.1)
	
	# Calculate movement based on accelerometer input
	var movement = Vector3(
		smoothed_accel.z * movement_speed,  # Move left/right
		smoothed_accel.y * movement_speed,  # Move up/down
		-smoothed_accel.x * movement_speed  # Move forward/backward
	)
	
	# The cup will only move slightly based on accelerometer input but will always return to the origin
	global_transform.origin = origin_position + movement
	
	var magnet: Vector3 = Input.get_magnetometer().rotated(-Vector3.FORWARD, rotation.z).rotated(Vector3.RIGHT, rotation.x)
	var gravity: Vector3 = Input.get_gravity()
	var roll_acc = atan2(-gravity.z, -gravity.y) 
	gravity = gravity.rotated(-Vector3.FORWARD, rotation.z)
	var pitch_acc = atan2(gravity.x, -gravity.y)
	var yaw_magnet = atan2(-magnet.z, magnet.x)
	
	var gyroscope: Vector3 = Input.get_gyroscope().rotated(-Vector3.FORWARD, roll)
	pitch = lerp_angle(pitch_acc, pitch + gyroscope.x * delta, k)
	yaw = lerp_angle(yaw_magnet, yaw + gyroscope.y * delta, k)
	roll = lerp_angle(roll_acc, roll + gyroscope.z * delta, k) 
	
	rotation = Vector3(pitch, yaw - initial_yaw, roll)


	
