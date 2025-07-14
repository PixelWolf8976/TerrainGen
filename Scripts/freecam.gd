extends Camera3D

var moveSpeed := 30.0
var lookSpeed := 2.0

func _ready() -> void:
	Global.player = self
	
	for key in Global.LODs.keys():
		var sphere: MeshInstance3D = MeshInstance3D.new()
		sphere.mesh = SphereMesh.new()
		sphere.scale = Vector3(key, key, key)
		add_child(sphere)

func _process(delta: float) -> void:
	var dir = Input.get_vector("Left", "Right", "Forward", "Backward")
	
	dir *= moveSpeed * delta
	
	dir = dir.rotated(-rotation.y)
	
	var movement: Vector3 = Vector3(dir.x, Input.get_axis("Down", "Up") * moveSpeed * delta, dir.y)
	
	position += movement
	
	rotation.y += Input.get_axis("Look Right", "Look Left") * lookSpeed * delta
	rotation.x += Input.get_axis("Look Down", "Look Up") * lookSpeed * delta
