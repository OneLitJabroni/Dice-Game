extends RigidBody3D

@onready var raycasts = $Raycasts.get_children()

signal roll_finished(value)

func _ready():
	print("!!!!!!!! DICE READY FIRED !!!!!!!!")
	sleeping = false
	
func _physics_process(_delta):
	if sleeping:
		print(name, " IS SLEEPING (checked via physics_process)")

func _on_sleeping_state_changed():
	print(name, " sleeping state changed, sleeping = ", sleeping)
	if sleeping:
		for raycast in raycasts:
			print(" - checking raycast: ", raycast.name, " colliding: ", raycast.is_colliding())
			if raycast.is_colliding():
				print(" - EMITTING roll_finished with value: ", raycast.opposite_side)
				roll_finished.emit(raycast.opposite_side)
			

# Update this method to accept the value
func _on_roll_finished(value):
	print("Roll finished for ", self.name, " with value:", value)
	# Here, you can process the value (e.g., update the UI, show the result, etc.)
