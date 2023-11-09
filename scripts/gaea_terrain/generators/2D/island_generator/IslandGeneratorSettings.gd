@tool
class_name IslandGeneratorSettings
extends GeneratorSettings2D

@export_group("Island settings", "island")
@export_range(0., 1.) var islandSpawnChance: float = .4
@export var grassTileInfo: IslandTileInfo

@export_range(16, 32) var islandMinSize: int = 16
@export_range(16, 32) var islandMaxSize: int = 32

@export_range(0., 1., 0.01) var islandHills: float = 1.

@export_subgroup("Falloff", "falloff")
@export var falloffEnabled: bool = false
@export var falloffMap: FalloffMap:
	set(value):
		falloffMap = value
		if falloffMap != null:
			falloffMap.size = Vector2i(islandMaxSize, islandMaxSize)

@export_group("World Settings")
## World size is messured in chunks
@export var worldSize: int = 50
@export var infinite: bool = true

@export_group("", "")
@export var noise: FastNoiseLite = FastNoiseLite.new()
@export var useRandomSeed := true
