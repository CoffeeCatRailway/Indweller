@tool
class_name IslandTileInfo
extends BetterTerrainTileInfo

#@export_range(-1., 1.) var threshold: float = 0
## The terrain [code]type[/code] to be used around tiles, -1 is empty/null & will erase cells
@export var outerType: int = -1
