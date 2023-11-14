class_name LagueIslandGenTest
extends Node

@export var tilemap: TileMap
@export var useRandomSeed := true

enum Layers
{
	GRASS = 0,
	SAND = 1,
	DIRT = 2,
	GRASS_HILL = 3,
	SAND_HILL = 4,
	WATER = 5
}

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var islandSize: int

var chunkScene: PackedScene = ResourceLoader.load("res://scenes/chunk.tscn")
#var thread: Thread

func _ready() -> void:
	rng.seed = "0".hash()
	if useRandomSeed:
		rng.randomize()
	
	var chunk: Chunk = chunkScene.instantiate() as Chunk
	tilemap.clear()
	
	generateChunk(Vector2i(0, 0), chunk)
	#generateChunk(Vector2i(1, 0), chunk)
	#generateChunk(Vector2i(1, 1), chunk)
	#generateChunk(Vector2i(0, 1), chunk)
	
	#thread = Thread.new()
	#if thread.is_alive() || thread.is_started():
	#	thread.wait_to_finish()
	#var callable := Callable(self, "generateDeferred")
	#thread.start(callable.bind(Vector2i(0, 0), chunk))

#func _exit_tree():
#	if thread.is_alive() || thread.is_started():
#		thread.wait_to_finish()

#func generateDeferred(chunkPos: Vector2i, chunk: Chunk) -> void:
#	call_thread_safe("generateChunk", chunkPos, chunk)

func generateChunk(chunkPos: Vector2i, chunk: Chunk) -> void:
	var timeNow: int = Time.get_ticks_msec()
	
	chunk.generate(rng)
	
	var chunkTilePos := chunkPos * Chunk.SIZE
	for x in Chunk.SIZE:
		for y in Chunk.SIZE:
			var tilePos: Vector2i = Vector2i(x, y)
			for layer in Layers.values():
				var sourceId: int = chunk.tilemap.get_cell_source_id(layer, tilePos)
				var atlasCoords: Vector2i = chunk.tilemap.get_cell_atlas_coords(layer, tilePos)
				var alternative: int = chunk.tilemap.get_cell_alternative_tile(layer, tilePos)
				
				tilemap.set_cell(layer, tilePos + chunkTilePos, sourceId, atlasCoords, alternative)
	
	var timeElapsed: int = Time.get_ticks_msec() - timeNow
	if OS.is_debug_build():
		print("%s: Generating chunk %s took %s seconds" % [name, chunkPos, float(timeElapsed) / 100])
	
	updateTerrains(chunkTilePos, true)

func updateTerrains(pos: Vector2i, updateSurrounding: bool = false) -> void:
	var timeNow: int = Time.get_ticks_msec()
	
	var area: Rect2i = Rect2i(pos, Vector2i(Chunk.SIZE - 1, Chunk.SIZE - 1))
	for layer in Layers.values():
		if layer == Layers.WATER:
			continue
		#BetterTerrain.call_deferred("update_terrain_area", tilemap, layer, area, updateSurrounding)
		BetterTerrain.update_terrain_area(tilemap, layer, area, updateSurrounding)
	
	var timeElapsed: int = Time.get_ticks_msec() - timeNow
	if OS.is_debug_build():
		print("%s: Updating terrains took %s seconds" % [name, float(timeElapsed) / 100])

func _process(_delta) -> void:
	if Input.is_action_just_released("ui_home"):
		_ready()
