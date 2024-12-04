extends CharacterBody3D


var speed = 5.0
var tilt_sensitivity = 2.0
var rotation_speed = 1.0

func _process(delta):
	var acceleration = Input.get_accelerometer()  # Get accelerometer data
	
	var tilt_vector = Vector3(acceleration.x, 0, acceleration.y) * tilt_sensitivity
	
	var gyro_data = Input.get_gyroscope()  # Get gyroscope data
	rotate_y(-gyro_data.x * rotation_speed * delta)  
	if tilt_vector.length() > 0.1:
		move_and_slide()
		 # Get gyroscope data
	rotate_y(-gyro_data.x * rotation_speed * delta)  # Rotate based on phone tilt  # For KinematicBody3D
	
	
	
