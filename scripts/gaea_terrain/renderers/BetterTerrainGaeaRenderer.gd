@tool
class_name BetterTerrainGaeaRenderer
extends GaeaRenderer2D
## Uses the [param tilemap] to draw the generator's [param grid]
## Takes [BetterTerrainTileInfo] to determine which tile to place in every cell
## This is a modified version of [TilemapGaeaRenderer]

@export var tilemap: TileMap:
	set(value):
		tilemap = value
		update_configuration_warnings()
@export var clearOnDraw := true
## Erases the cell when an empty tile is found. Recommended: true
@export var eraseEmptyTiles := true

func _draw_area(area: Rect2i) -> void:
	var terrains: Dictionary
	
	for x in range(area.position.x, area.end.x + 1):
		for y in range(area.position.y, area.end.y + 1):
			var tilePos := Vector2i(x, y)
			if not generator.grid.has_cell(tilePos):
				if not eraseEmptyTiles:
					continue
				
				for l in range(tilemap.get_layers_count()):
					tilemap.erase_cell(l, tilePos) # [TilemapGaeaRenderer] makes a new vector here?
				continue
			
			var tileInfo = generator.grid.get_value(tilePos)
			if not (tileInfo is BetterTerrainTileInfo):
				continue
			
			if not terrains.has(tileInfo):
				terrains[tileInfo] = [tilePos]
			else:
				terrains[tileInfo].append(tilePos)
	
	for tileInfo in terrains:
		BetterTerrain.set_cells(tilemap, tileInfo.layer, terrains[tileInfo], tileInfo.type)
	for l in range(tilemap.get_layers_count()):
		BetterTerrain.update_terrain_area(tilemap, l, area) # Find a way to only update modified layers

func _draw() -> void:
	if clearOnDraw:
		tilemap.clear()
	super._draw()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray
	warnings.append_array(super._get_configuration_warnings())
	
	if not is_instance_valid(tilemap):
		warnings.append("Needs a Tilemap to work.")
	return warnings
