extends Node

var chunkSize: float = 100.0
var player
var chunks := []
var iterator := 0

var LODs: Dictionary = { # Distance from player : Chunk resolution in quads
	100: 100,
	200: 50,
	300: 25,
	400: 10,
	500: 10 # Last one is needed to set chunks to their lowest res
}

#func _process(delta: float) -> void: # Idea in area around player check what res should be
	#for i in range(delta * 500.0):
		#chunks[iterator].updateChunk()
		##print(chunks[iterator].get_groups())
		#iterator += 1
		#if iterator >= chunks.size():
			#iterator = 0

func getRes(distance: float):
	var keys := LODs.keys()
	keys.reverse()
	for key in keys:
		if distance > key:
			return LODs[key]
	
	return LODs[keys.back()]
