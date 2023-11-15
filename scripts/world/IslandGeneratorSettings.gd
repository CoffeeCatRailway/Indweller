@tool
class_name IslandGeneratorSettings
extends Resource

@export var seedOverride: String = "0"
@export var numericalSeed: bool = false
@export_range(0., 1.) var chance: float = .5
@export var falloff: FalloffMap
@export_range(0., 1.) var randomFillPercent: float = .55 ##.475
@export_range(0, 10) var smoothLevel: int = 5

@export_group("Shoreline settings", "shoreline")
@export var shorelineBeaches: bool = true
@export_range(0, 10) var shorelineSmoothLevel: int = 2
@export_range(0., 1.) var shorelineThreshold: float = .15

@export_group("Hill settings", "hill")
@export_range(0., 1.) var hillChance: float = .75
@export_range(0., 1.) var hillSmooth1: float = .15
@export_range(0, 10) var hillSmooth2: int = 4
@export_range(0., 1.) var hillSmooth3: float = .1

func _init() -> void:
	if resource_name == "":
		resource_name = "Settings"
		
