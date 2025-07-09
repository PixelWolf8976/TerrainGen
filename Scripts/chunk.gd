extends Node3D

@onready var mesh := $MeshInstance3D

@export var resolution: int = 100 # Number of quads along each axis
@export var amplitude: float = 50.0 # How much the hight noise effects height

var oldRes = 0

func _ready():
	updateChunk()

func updateChunk():
	var newRes = Global.getRes((Global.player.position - position).length())
	if oldRes != newRes:
		mesh.mesh = generateChunk(newRes, Global.chunkSize)

func generateChunk(resolution: int, size: float) -> ArrayMesh:
	var noise := FastNoiseLite.new()
	#noise.seed = 0
	noise.frequency = 0.005
	
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
