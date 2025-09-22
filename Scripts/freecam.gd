extends Camera3D

var moveSpeed := 100.0
var lookSpeed := 2.0

func _ready() -> void:
	Global.player = self
	
	for key in Global.LODs.keys():
		var newArea3D := Area3D.new()
		var newSphere := SphereShape3D.new()
		var newCollision := CollisionShape3D.new()
		
		newSphere.radius = key
		newArea3D.name = str(Global.LODs[key])
		newCollision.shape = newSphere
		
		newArea3D.body_entered.connect(onAreaEntered.bind(newArea3D.name))
		newArea3D.body_exited.connect(onAreaEntered.bind(newArea3D.name))
		
		newArea3D.add_child(newCollision)
		add_child(newArea3D)

func onAreaEntered(body: Node3D, areaResolution: String):
	var areaResNum: int = int(areaResolution)
	
	if body.get_parent().has_method("setChunk"):
		body.get_parent().setChunk(areaResNum)

func _process(delta: float) -> void:
	var dir = Input.get_vector("Left", "Right", "Forward", "Backward")
	
	dir *= moveSpeed * delta
	
	dir = dir.rotated(-rotation.y)
	
	var movement: Vector3 = Vector3(dir.x, Input.get_axis("Down", "Up") * moveSpeed * delta, dir.y)
	
	position += movement
	
	rotation.y += Input.get_axis("Look Right", "Look Left") * lookSpeed * delta
	rotation.x += Input.get_axis("Look Down", "Look Up") * lookSpeed * delta
	
	if Input.is_action_just_pressed("Spawn Ball"):
		var ball = load("res://Scenes/ball.tscn").instantiate()
		ball.position = position
		add_sibling(ball)
