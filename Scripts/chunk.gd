extends Node3D

@onready var mesh := $MeshInstance3D
@onready var col := $StaticBody3D/CollisionShape3D

var noise := FastNoiseLite.new()

var lods: Dictionary = {}

var oldRes: int = 0

func _ready():
	noise.frequency = Global.noiseFrequency
	noise.fractal_octaves = Global.noiseOctaves
	
	if Global.noiseSeed != 0:
		noise.seed = Global.noiseSeed
	
	col.shape = HeightMapShape3D.new()
	col.shape.map_depth = Global.collisionRes + 1.0
	col.shape.map_width = Global.collisionRes + 1.0
	col.scale = Vector3(100.0 / Global.collisionRes, 1.0, 100.0 / Global.collisionRes)
	genCol()
	
	renderChunk()
	
	add_to_group(str(oldRes))

func getHeight(x: float, z: float) -> float:
	#return noise.get_noise_2d(x, z) * 50.0
	var heightNoise: FastNoiseLite = FastNoiseLite.new()
	heightNoise.frequency = 0.00025
	heightNoise.fractal_octaves = 1
	
	if Global.noiseSeed != 0:
		heightNoise.seed = Global.noiseSeed
	
	var heightModifyer = heightNoise.get_noise_2d(x, z)
	
	var positiveHeight = noise.get_noise_2d(x, z) * ((0.5 + (heightModifyer / 2.0)) * 100.0)
	var negativeHeight = heightModifyer * 500.0
	
	return lerpf(positiveHeight, negativeHeight, (clampf(heightModifyer, -1, 1) / 2.0) + 0.5)

func genCol():
	var currentVert: int = 0
	
	var stepSize := Global.chunkSize / Global.collisionRes
	
	for x in range(Global.collisionRes + 1):
		for z in range(Global.collisionRes + 1):
			var world_x: float = (x - (Global.collisionRes / 2.0)) * stepSize
			var world_z: float = (z - (Global.collisionRes / 2.0)) * stepSize
			var height = getHeight(world_x + position.x, world_z + position.z)
			
			col.shape.map_data[currentVert] = height
			currentVert += 1

func renderChunk():
	var res = Global.getRes((Global.player.position - position).length() - (Global.chunkSize / 2.0))
	setChunk(res)

func setChunk(resolution: int):
	if Global.DEBUG:
		mesh.material_override = StandardMaterial3D.new()
		var foo := float(resolution) / 100.0
		var chunkColor := Color(1, 0, 0).lerp(Color(0, 1, 0), foo)
		mesh.material_override.albedo_color = chunkColor
	
	mesh.mesh = generateChunk(resolution, Global.chunkSize)

func generateChunk(resolution: int, size: float) -> ArrayMesh:
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
			var height = getHeight(world_x + position.x, world_z + position.z)
			
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
