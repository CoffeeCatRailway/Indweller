@tool
class_name IslandGenerator
extends ChunkAwareGenerator2D

@export var settings: IslandGeneratorSettings

func _ready() -> void:
	if settings.useRandomSeed:
		settings.noise.seed = randi()
	super._ready()

func generate(startingGrid: GaeaGrid = null) -> void:
	var timeNow: int = Time.get_ticks_msec()
	
	if not settings:
		push_error("%s doesn't have settings resource" % name)
		return
	
	if startingGrid == null:
		erase()
	else:
		grid = startingGrid
	
	_set_grid()
	_apply_modifiers(settings.modifiers)
	
	if is_instance_valid(next_pass):
		next_pass.generate(grid)
		return
	
	var timeElapsed: int = Time.get_ticks_msec() - timeNow
	if OS.is_debug_build():
		print("%s: Generating took %s second" % [name, float(timeElapsed) / 100])
	
	grid_updated.emit()

func generate_chunk(chunkPos: Vector2i, startingGrid: GaeaGrid = null) -> void:
	var timeNow: int = Time.get_ticks_msec()
	
	if not settings:
		push_error("%s doesn't have settings resource" % name)
		return
	
	if startingGrid == null:
		erase_chunk(chunkPos)
	else:
		grid = startingGrid
	
	_set_grid_chunk(chunkPos)
	_apply_modifiers_chunk(settings.modifiers, chunkPos)
	
	generated_chunks.append(chunkPos)
	
	if is_instance_valid(next_pass):
		if not next_pass is ChunkAwareGenerator2D:
			push_error("next_pass, generator is not a ChunkAwareGenerator2D")
		else:
			next_pass.generate_chunk(chunkPos, grid)
			return
	
	var timeElapsed: int = Time.get_ticks_msec() - timeNow
	if OS.is_debug_build():
		print("%s: Generating chunk %s took %s second" % [name, chunkPos, float(timeElapsed) / 100])
	
	chunk_updated.emit(chunkPos)

func _set_grid() -> void:
	var worldSizeInTiles := settings.worldSize * chunk_size
	_set_grid_area(Rect2i(Vector2i.ZERO, Vector2i(worldSizeInTiles, worldSizeInTiles)))

func _set_grid_chunk(chunkPos: Vector2i) -> void:
	_set_grid_area(Rect2i(
		chunkPos * chunk_size,
		Vector2i(chunk_size, chunk_size)
	))

func _set_grid_area(rect: Rect2i) -> void:
	var chance = (settings.noise.get_noise_2dv(rect.position) + 1.) / 2.
	if chance > settings.islandSpawnChance:
		return
	
	for x in range(rect.position.x, rect.end.x):
		if not settings.infinite:
			if x < 0 or x > settings.worldSize * chunk_size:
				continue
		
		for y in range(rect.position.y, rect.end.y):
			if not settings.infinite:
				if y < 0 or y > settings.worldSize * chunk_size:
					continue
			
			var noise = settings.noise.get_noise_2d(x, y)
			if settings.falloffEnabled and settings.falloffMap:
				noise = ((noise + 1) * settings.falloffMap.get_value(Vector2i(x, y) - rect.position)) - 1.
			
			if noise > -.5:
				grid.set_valuexy(x, y, settings.grassTileInfo)





















