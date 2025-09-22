extends Node3D

var worldSize: int = 100 # World size in chunks

var chunk := preload("res://Scenes/chunk.tscn")

func _ready() -> void:
	for x in range(worldSize):
		for z in range(worldSize):
			var xPos: float = (x - ((worldSize / 2.0) - 1.0)) * Global.chunkSize
			var zPos: float = (z - ((worldSize / 2.0) - 1.0)) * Global.chunkSize
			
			var currChunk := chunk.instantiate()
			currChunk.position = Vector3(xPos, 0, zPos)
			Global.chunks.append(currChunk)
			add_child(currChunk)
