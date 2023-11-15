class_name Chunk
extends Node2D

const SIZE: int = 48

@export var islandGenerator: IslandGenerator
@export var tilemap: TileMap
@export var islandSettings: IslandGeneratorSettings

func generate(rng: RandomNumberGenerator) -> void:
	generateEmptyChunk()
	
	if rng.randf() < islandSettings.chance:
		islandGenerator.generateIsland(rng, islandSettings, tilemap)

func generateEmptyChunk() -> void:
	var timeNow: int = Time.get_ticks_msec()
	
	tilemap.clear()
	var posArray: Array = []
	
	for x in Chunk.SIZE:
		for y in Chunk.SIZE:
			var tilePos := Vector2i(x, y)
			posArray.append(tilePos)
			tilemap.set_cell(LagueIslandGenTest.Layers.WATER, tilePos, 6, Vector2i.ZERO)
	
	BetterTerrain.set_cells(tilemap, LagueIslandGenTest.Layers.GRASS, posArray, 1)
	BetterTerrain.set_cells(tilemap, LagueIslandGenTest.Layers.SAND, posArray, 5)
	BetterTerrain.set_cells(tilemap, LagueIslandGenTest.Layers.DIRT, posArray, 3)
	BetterTerrain.set_cells(tilemap, LagueIslandGenTest.Layers.GRASS_HILL, posArray, 6)
	BetterTerrain.set_cells(tilemap, LagueIslandGenTest.Layers.SAND_HILL, posArray, 7)
	
	var timeElapsed: int = Time.get_ticks_msec() - timeNow
	if OS.is_debug_build():
		print("%s: Resetting tilemap took %s seconds" % [name, float(timeElapsed) / 100])
