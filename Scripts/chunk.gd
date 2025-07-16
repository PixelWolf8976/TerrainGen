extends Node3D

@onready var mesh := $MeshInstance3D
@onready var col := $StaticBody3D/CollisionShape3D

@export var amplitude: float = 50.0 # How much the hight noise effects height

var oldRes = 0

func _ready():
	col.shape = HeightMapShape3D.new()
	updateChunk()
	add_to_group(str(oldRes))

func updateChunk():
	var newRes = Global.getRes((Global.player.position - position).length())
	
	if oldRes != newRes:
		var needsCol := false
		if newRes <= Global.LODs.keys()[0]:
			needsCol = true
		
		remove_from_group(str(oldRes))
		add_to_group(str(newRes))
		mesh.mesh = generateChunk(newRes, Global.chunkSize, needsCol)

func generateChunk(resolution: int, size: float, genCol: bool) -> ArrayMesh:
	var currentVert := 0
	
	if genCol:
		col.shape.map_depth = resolution + 1.0
		col.shape.map_width = resolution + 1.0
	else:
		col.shape.map_depth = 0
		col.shape.map_width = 0
	
	var noise := FastNoiseLite.new()
	#noise.seed = 0
	noise.frequency = 0.005
	noise.fractal_octaves = 1
	
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var step = size / resolution
	var verts = []
	
	# Generate vertex grid with height
	for x in range(resolution + 1):
		verts.append([])
		for z in range(resolution + 1):
			var world_x = (x - (resolution / 2.0)) * step
			var world_z = (z - (resolution / 2.0)) * step
			var height = noise.get_noise_2d(world_x + position.x, world_z + position.z) * amplitude
			
			if genCol:
				col.shape.map_data[currentVert] = height
				currentVert += 1
			
			var vertex = Vector3(world_x, height, world_z)
			verts[x].append(vertex)
	
	# Build triangles from the vertex grid
	for x in range(resolution):
		for z in range(resolution):
			var v0 = verts[x][z]
			var v1 = verts[x+1][z]
			var v2 = verts[x][z+1]
			var v3 = verts[x+1][z+1]
			
			# Triangle 1
			st.set_uv(Vector2(x / resolution, z / resolution))
			st.add_vertex(v0)
			st.set_uv(Vector2((x+1) / resolution, z / resolution))
			st.add_vertex(v1)
			st.set_uv(Vector2(x / resolution, (z+1) / resolution))
			st.add_vertex(v2)
			
			# Triangle 2
			st.set_uv(Vector2((x+1) / resolution, z / resolution))
			st.add_vertex(v1)
			st.set_uv(Vector2((x+1) / resolution, (z+1) / resolution))
			st.add_vertex(v3)
			st.set_uv(Vector2(x / resolution, (z+1) / resolution))
			st.add_vertex(v2)
	
	st.set_smooth_group(1)
	st.generate_normals()
	return st.commit()
