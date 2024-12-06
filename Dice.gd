extends RigidBody3D


@onready var raycasts = $Raycasts.get_children()
var start_pos
var roll_strength = 175



signal roll_finished(value)





func roll():
	#reset state
	sleeping = false
	freeze = false
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	
	#random rotation
	transform.basis = Basis(Vector3.RIGHT, randf_range(0, 2 * PI)) * transform.basis
	transform.basis = Basis(Vector3.UP, randf_range(0, 2 * PI)) * transform.basis
	transform.basis = Basis(Vector3.FORWARD, randf_range(0, 2 * PI)) * transform.basis
	
	#random throw impulse
	var throw_vector = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
	angular_velocity = throw_vector * roll_strength / 2
	apply_central_impulse(throw_vector * roll_strength)
	

	


	


func _on_sleeping_state_changed():
	if sleeping:
		for raycast in raycasts:
			if raycast.is_colliding():
				roll_finished.emit(raycast.opposite_side)
			
			
# Update this method to accept the value
func _on_roll_finished(value):
	print("Roll finished for", self.name, "with value:", value)
	# Here, you can process the value (e.g., update the UI, show the result, etc.)
