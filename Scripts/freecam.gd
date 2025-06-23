extends Camera3D

var moveSpeed := 1.5
var lookSpeed := 1.0

func _process(delta: float) -> void:
	var dir = Input.get_vector("Left", "Right", "Forward", "Backward")
	
	dir *= moveSpeed * delta
	
	dir = dir.rotated(-rotation.y)
	
	var movement: Vector3 = Vector3(dir.x, Input.get_axis("Down", "Up") * moveSpeed * delta, dir.y)
	
	position += movement
	
	rotation.y += Input.get_axis("Look Right", "Look Left") * lookSpeed * delta
	rotation.x += Input.get_axis("Look Down", "Look Up") * lookSpeed * delta
	
	#print(position)
	#print(rotation)
	#print("")
