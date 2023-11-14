class_name IslandGenerator
extends Node

var settings: IslandGeneratorSettings

const SPIT_IMAGE: bool = true

func generateIsland(rng: RandomNumberGenerator, settings: IslandGeneratorSettings, tilemap: TileMap) -> void:
	self.settings = settings
	var timeNow: int = Time.get_ticks_msec()
	
	var rngSeed := rng.seed
	var rngState := rng.state
	
	if settings.seedOverride != "0":
		rng.seed = int(settings.seedOverride) if settings.numerialSeed else settings.seedOverride.hash()
		rng.state = 0
	
	var islandGrid: Array = createEmpty2DArray(0., Chunk.SIZE, Chunk.SIZE)
	
	## Fill & smooth grid for base island shape
	randomFillGrid(rng, islandGrid)
	
	for x in Chunk.SIZE:
		for y in Chunk.SIZE:
			if distanceSqr(x, y, Chunk.SIZE) < settings.fallOffInner:
				islandGrid[x][y] = 0
	
	for i in settings.smoothLevel:
		smoothGrid(islandGrid)
	
	## Blur grid for shoreline
	if settings.shorelineBeaches:
		blurGrid(islandGrid, settings.shorelineSmoothLevel)
	
	var spitImage: Image
	if SPIT_IMAGE:
		spitImage = Image.create(Chunk.SIZE, Chunk.SIZE, false, Image.FORMAT_RGBA8)
	
	## Place ground (grass, sand, dirt)
	for x in Chunk.SIZE:
		for y in Chunk.SIZE:
			var value = islandGrid[x][y]
			var tilePos: Vector2i = Vector2i(x, y)
			
			if value > settings.shorelineThreshold:
				BetterTerrain.set_cell(tilemap, LagueIslandGenTest.Layers.GRASS, tilePos, 0) # grass
			if value > 0.:
				if settings.shorelineBeaches and value <= settings.shorelineThreshold:
					BetterTerrain.set_cell(tilemap, LagueIslandGenTest.Layers.SAND, tilePos, 4) # sand
				BetterTerrain.set_cell(tilemap, LagueIslandGenTest.Layers.DIRT, tilePos, 2) # dirt
				
			if SPIT_IMAGE:
				spitImage.set_pixel(x, y, Color(value, value, value))
	
	if SPIT_IMAGE:
		spitImage.save_png("user://spat_images/chunk_%s.png" % [rngSeed])
	
	## Place hills
	if settings.hillEnabled:
		smoothGrid(islandGrid, settings.hillSmooth1)
		blurGrid(islandGrid, settings.hillSmooth2)
		smoothGrid(islandGrid, settings.hillSmooth3)
		for x in Chunk.SIZE:
			for y in Chunk.SIZE:
				var value = islandGrid[x][y]
				if value > .9: # hard coded threshold for now
					BetterTerrain.set_cell(tilemap, LagueIslandGenTest.Layers.GRASS_HILL, Vector2i(x, y), 0)
					
				if SPIT_IMAGE:
					spitImage.set_pixel(x, y, Color(value, value, value))
		
		if SPIT_IMAGE:
			spitImage.save_png("user://spat_images/chunk_%s_hills.png" % [rngSeed])
	
	if settings.seedOverride != "0":
		rng.seed = rngSeed
		rng.state = rngState
		
	var timeElapsed: int = Time.get_ticks_msec() - timeNow
	if OS.is_debug_build():
		print("%s: Generating island took %s seconds" % [name, float(timeElapsed) / 100])
		
func createEmpty2DArray(defaultValue, width: int, height: int) -> Array:
	var array = []
	for x in width:
		array.append([])
		for y in height:
			array[x].append(defaultValue)
	return array

## https://github.com/SebLague/Procedural-Cave-Generation/blob/master/Episode%2009/MapGenerator.cs#L291
func randomFillGrid(rng: RandomNumberGenerator, grid: Array) -> void:
	for x in grid.size():
		for y in grid.size():
			var fill: float = 1. if rng.randf() < settings.randomFillPercent else 0.
			if distanceSqr(x, y, Chunk.SIZE) > settings.fallOffOuter:
				fill = 0.
			if distanceSqr(x, y, Chunk.SIZE) < settings.fallOffInner:
				fill = 0.
			grid[x][y] = fill

func distanceSqr(x: int, y: int, size: int) -> float:
	var dx: float = 2. * float(x) / float(size) - 1.
	var dy: float = 2. * float(y) / float(size) - 1.
	# 0 <= dx <= 1 and 0 <= dy <= 1
	return dx * dx + dy * dy

## https://github.com/SebLague/Procedural-Cave-Generation/blob/master/Episode%2009/MapGenerator.cs#L311
func smoothGrid(grid: Array, threshold: float = 0.) -> void:
	for x in grid.size():
		for y in grid.size():
			var neighbours: int = getNeighbourCount(grid, x, y, 1, threshold)
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
func getNeighbourCount(grid: Array, x: int, y: int, neighbourRange: int = 1, threshold: float = 0.) -> int:
	var neighbours: int = 0
	for nx in range(x - neighbourRange, x + neighbourRange + 1):
		for ny in range(y - neighbourRange, y + neighbourRange + 1):
			if inRange(grid.size(), nx, ny):
				if nx != x or ny != y:
					if grid[nx][ny] <= threshold:
						neighbours += 1
			else:
				neighbours += 1
	return neighbours

func inRange(size: int, x: int, y: int) -> bool:
	return x >= 0 and x < size and y >= 0 and y < size
