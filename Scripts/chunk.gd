@tool
extends Node3D

@onready var mesh: ArrayMesh = $MeshInstance3D.mesh
@onready var mesh_instance := $MeshInstance3D

@export var chunk_size := 4
@export var chunk_scale := 1.0
@export var regenerate: bool = false:
	set(value):
		if value:
			regenerate = false
			_generate_mesh()

func _ready() -> void:
	_generate_mesh()

func _generate_mesh():
	if mesh == null:
		mesh = ArrayMesh.new()
		mesh_instance.mesh = mesh

	mesh.clear_surfaces()

	var verts := PackedVector3Array()
	var uvs := PackedVector2Array()
	var normals := PackedVector3Array()
	var indices := PackedInt32Array()

	# Generate full grid of vertices
	for z in range(chunk_size):
		for x in range(chunk_size):
			verts.append(Vector3(x * chunk_scale, 0, z * chunk_scale))
			uvs.append(Vector2(x / float(chunk_size - 1), z / float(chunk_size - 1)))
			normals.append(Vector3.UP)

	# Print vertex count
	var vcount = verts.size()
	print("Vertex count: ", vcount)

	# Generate triangle indices
	for z in range(chunk_size - 1):
		for x in range(chunk_size - 1):
			var top_left := x + z * chunk_size
			var top_right := top_left + 1
			var bottom_left := top_left + chunk_size
			var bottom_right := bottom_left + 1

			for i in [top_left, bottom_left, top_right, top_right, bottom_left, bottom_right]:
				if i >= vcount:
					push_error("‼️ INVALID INDEX: " + str(i) + " >= " + str(vcount))
				else:
					indices.append(i)

	# Final print
	print("Index count: ", indices.size())

	# Prepare mesh
	var surface := []
	surface.resize(Mesh.ARRAY_MAX)
	surface[Mesh.ARRAY_VERTEX] = verts
	surface[Mesh.ARRAY_TEX_UV] = uvs
	surface[Mesh.ARRAY_NORMAL] = normals
	surface[Mesh.ARRAY_INDEX] = indices

	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface)

	# Optional material
	if mesh.get_surface_count() > 0:
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(1.0, 0.6, 0.4)
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mesh_instance.set_surface_override_material(0, mat)
