extends Node3D

@export var resolution: float = 0.5  # Size of one triangle's side
@export var size: float = 100.0

func _ready():
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = generate_plane_mesh(resolution, size)
	add_child(mesh_instance)

func generate_plane_mesh(resolution: float, size: float) -> ArrayMesh:
	var mesh := ArrayMesh.new()
	
	var width := size
	var height := size
	
	var cols := int(width / resolution)
	var rows := int(height / resolution)
	
	var vertices := PackedVector3Array()
	var indices := PackedInt32Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	
	for y in range(rows):
		for x in range(cols):
			var x0 := x * resolution - width * 0.5
			var x1 := (x + 1) * resolution - width * 0.5
			var z0 := y * resolution - height * 0.5
			var z1 := (y + 1) * resolution - height * 0.5
			
			var positionalOffset := Vector2(position.x, position.y)
			
			var globalBL := Vector2(x0, z0) + positionalOffset
			var globalBR := Vector2(x1, z0) + positionalOffset
			var globalTL := Vector2(x0, z1) + positionalOffset
			var globalTR := Vector2(x1, z1) + positionalOffset
			
			var noise: FastNoiseLite = FastNoiseLite.new()
			#noise.frequency = 
			
			var y0 := noise.get_noise_2dv(globalBL) * 10.0
			var y1 := noise.get_noise_2dv(globalBR) * 10.0
			var y2 := noise.get_noise_2dv(globalTL) * 10.0
			var y3 := noise.get_noise_2dv(globalTL) * 10.0
			
			# Bottom-left
			var v0 := Vector3(x0, y0, z0)
			# Bottom-right
			var v1 := Vector3(x1, y1, z0)
			# Top-left
			var v2 := Vector3(x0, y2, z1)
			# Top-right
			var v3 := Vector3(x1, y3, z1)
			
			var base_index := vertices.size()
			
			# Triangle 1 (v0, v1, v2)
			vertices.append_array([v0, v1, v2])
			indices.append_array([base_index, base_index + 1, base_index + 2])
			# Triangle 2 (v2, v1, v3)
			vertices.append_array([v2, v1, v3])
			indices.append_array([base_index + 3, base_index + 4, base_index + 5])
			
			# Add normals and uvs for each vertex
			for i in range(6):
				normals.append(Vector3.UP)
			
			uvs.append_array([
				Vector2(x0, z0), Vector2(x1, z0), Vector2(x0, z1),
				Vector2(x0, z1), Vector2(x1, z0), Vector2(x1, z1)
			])
	
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh
