class_name LagueIslandGenTest
extends Node

@export var tilemap: TileMap

@export var useRandomSeed := true
@export_range(16, 32, 1, "or_greater") var islandMinSize: int = 16
@export_range(16, 32, 1, "or_greater") var islandMaxSize: int = 32
@export_range(0., .1) var fallOffPercent: float = .05
@export_range(.45, .6) var randomFillPercent: float = .5 ##.475
@export_range(0, 10) var smoothLevel: int = 5
@export_range(0, 10) var shorelineBlurLevel: int = 2
@export_range(0., 1.) var shoreline: float = .15

const GRASS_LAYER: int = 0
const SAND_LAYER: int = 1
const DIRT_LAYER: int = 2
const GRASS_HILL_LAYER: int = 3
const SAND_HILL_LAYER: int = 4
const WATER_LAYER: int = 5

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var islandSize: int

func _ready() -> void:
	rng.seed = "0".hash()
	if useRandomSeed:
		rng.randomize()
	
	islandSize = rng.randi_range(islandMinSize, islandMaxSize)
	
	resetTilemap()
	
	generate(Vector2i.ZERO, true)
	
	#generate(Vector2i(islandSize, 0))
	#updateTerrains(Vector2i(islandSize, 0))
	
	generate(Vector2i(islandSize, islandSize))
	#updateTerrains(Vector2i(islandSize, islandSize))
	
	#generate(Vector2i(0, islandSize))
	#updateTerrains(Vector2i(0, islandSize))

func resetTilemap() -> void:
	var timeNow: int = Time.get_ticks_msec()
	
	tilemap.clear()
	var posArray: Array = []
	
	for x in islandSize * 2:
		for y in islandSize * 2:
			var pos := Vector2i(x, y)
			posArray.append(pos)
			tilemap.set_cell(WATER_LAYER, pos, 6, Vector2i.ZERO)
	
	BetterTerrain.set_cells(tilemap, GRASS_LAYER, posArray, 1)
	BetterTerrain.set_cells(tilemap, SAND_LAYER, posArray, 5)
	BetterTerrain.set_cells(tilemap, DIRT_LAYER, posArray, 3)
	BetterTerrain.set_cells(tilemap, GRASS_HILL_LAYER, posArray, 6)
	BetterTerrain.set_cells(tilemap, SAND_HILL_LAYER, posArray, 7)
	
	var timeElapsed: int = Time.get_ticks_msec() - timeNow
	if OS.is_debug_build():
		print("%s: Resetting tilemap took %s seconds" % [name, float(timeElapsed) / 100])

func updateTerrains(pos: Vector2i) -> void:
	var timeNow: int = Time.get_ticks_msec()
	
	var area: Rect2i = Rect2i(pos, Vector2i(islandSize - 1, islandSize - 1))
	BetterTerrain.update_terrain_area(tilemap, GRASS_LAYER, area, false)
	BetterTerrain.update_terrain_area(tilemap, SAND_LAYER, area, false)
	BetterTerrain.update_terrain_area(tilemap, DIRT_LAYER, area, false)
	BetterTerrain.update_terrain_area(tilemap, GRASS_HILL_LAYER, area, false)
	BetterTerrain.update_terrain_area(tilemap, SAND_HILL_LAYER, area, false)
	
	var timeElapsed: int = Time.get_ticks_msec() - timeNow
	if OS.is_debug_build():
		print("%s: Updating terrains took %s seconds" % [name, float(timeElapsed) / 100])

func generate(pos: Vector2i, doSpitImage: bool = false) -> void:
	var timeNow: int = Time.get_ticks_msec()
	
	var islandGrid = createEmpty2DArray(0., islandSize, islandSize)
	
	## Fill & smooth grid for base island shape
	randomFillGrid(islandGrid)
	for i in smoothLevel:
		smoothGrid(islandGrid)
	
	## Blur grid for shoreline
	blurGrid(islandGrid, shorelineBlurLevel)
	
	var spitImage: Image
	if doSpitImage:
		spitImage = Image.create(islandSize, islandSize, false, Image.FORMAT_RGBA8)
	
	## Place ground (grass, sand, dirt)
	for x in islandSize:
		for y in islandSize:
			var value = islandGrid[x][y]
			var tilePos: Vector2i = Vector2i(x, y) + pos
			
			if value > shoreline:
				BetterTerrain.set_cell(tilemap, GRASS_LAYER, tilePos, 0) # grass
			if value > 0.:
				if value <= shoreline:
					BetterTerrain.set_cell(tilemap, SAND_LAYER, tilePos, 4) # sand
				BetterTerrain.set_cell(tilemap, DIRT_LAYER, tilePos, 2) # dirt
				
			if doSpitImage:
				spitImage.set_pixel(x, y, Color(value, value, value))
	
	if doSpitImage:
		spitImage.save_png("user://spat_images/%s_%s.png" % [pos.x, pos.y])
	
	## Place hills
	smoothGrid(islandGrid, .15)
	blurGrid(islandGrid, 4)
	smoothGrid(islandGrid, .1)
	for x in islandSize:
		for y in islandSize:
			var value = islandGrid[x][y]
			if value > .9:
				BetterTerrain.set_cell(tilemap, GRASS_HILL_LAYER, Vector2i(x, y) + pos, 0)
				
			if doSpitImage:
				spitImage.set_pixel(x, y, Color(value, value, value))
	
	if doSpitImage:
		spitImage.save_png("user://spat_images/%s_%s_hills.png" % [pos.x, pos.y])
	
	var timeElapsed: int = Time.get_ticks_msec() - timeNow
	if OS.is_debug_build():
		print("%s: Generating took %s seconds" % [name, float(timeElapsed) / 100])
	
	updateTerrains(pos)

func createEmpty2DArray(defaultValue, width: int, height: int) -> Array:
	var array = []
	for x in width:
		array.append([])
		for y in height:
			array[x].append(defaultValue)
	return array

## https://github.com/SebLague/Procedural-Cave-Generation/blob/master/Episode%2009/MapGenerator.cs#L291
func randomFillGrid(grid: Array) -> void:
	for x in grid.size():
		for y in grid.size():
			#if x == 0 or x == grid.size() - 1 or y == 0 or y == grid.size() - 1:
			#	grid[x][y] = 1
			#else:
				var fallOff: float = distanceSqr(x, y, grid.size()) * fallOffPercent
				var fill: float = clampf(rng.randf() - fallOff, 0., 1.)
				if fill < randomFillPercent:
					grid[x][y] = 1.
				else:
					grid[x][y] = 0.

func distanceSqr(x: int, y: int, size: int) -> float:
	var dx: float = 2. * float(x) / float(size) - 1.
	var dy: float = 2. * float(y) / float(size) - 1.
	# 0 <= dx <= 1 and 0 <= dy <= 1
	return dx * dx + dy * dy

## https://github.com/SebLague/Procedural-Cave-Generation/blob/master/Episode%2009/MapGenerator.cs#L311
func smoothGrid(grid: Array, threshold: float = 0.) -> void:
	for x in grid.size():
		for y in grid.size():
			var neighbours: int = getNeighbourCount(grid, x, y, 1., threshold)
			if neighbours > 4:
				grid[x][y] = 0.
			elif neighbours < 4:
				grid[x][y] = 1.

func blurGrid(grid: Array, blur: int, threshold: float = 0.) -> void:
	for x in grid.size():
		for y in grid.size():
			var neighbours = getNeighbourCount(grid, x, y, blur, threshold)
			grid[x][y] /= neighbours

## https://github.com/SebLague/Procedural-Cave-Generation/blob/master/Episode%2009/MapGenerator.cs#L325
func getNeighbourCount(grid: Array, x: int, y: int, range: int = 1, threshold: float = 0.) -> int:
	var neighbours: int = 0
	for nx in range(x - range, x + range + 1):
		for ny in range(y - range, y + range + 1):
			if inRange(grid.size(), nx, ny):
				if nx != x or ny != y:
					if grid[nx][ny] <= threshold:
						neighbours += 1
			else:
				neighbours += 1
	return neighbours

func inRange(size: int, x: int, y: int) -> bool:
	return x >= 0 and x < size and y >= 0 and y < size










