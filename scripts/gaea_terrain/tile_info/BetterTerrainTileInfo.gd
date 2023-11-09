@tool
class_name BetterTerrainTileInfo
extends TileInfo

enum InfoType
{
	SINGLE_CELL, ## Just a single tile/cell.
	TERRAIN ## Terrain type to be used.
}

@export var infoType: InfoType = InfoType.TERRAIN:
	set(value):
		infoType = value
		notify_property_list_changed()
## The [TileMap] layer the tile will be placed in.
@export var layer: int = 0

## The terrain [code]type[/code], -1 is empty/null & will erase cells
var type: int = -1

## A [TileSetSource] identifier. If set to [code]-1[/code], the cell will be erased.
var sourceId: int = 0
## Tiles coordinates in the atlas. If set to [code]Vector2i(-1, -1)[/code], the cell will be erased.
var atlasCoord: Vector2i = Vector2i.ZERO
## Tile alternative in the atlas. If set to [code]-1[/code], the cell will be erased.
var alternativeTile: int = 0

func _get_property_list() -> Array[Dictionary]:
	match infoType:
		InfoType.SINGLE_CELL:
			return [
				{
					"name": "sourceId",
					"usage": PROPERTY_USAGE_DEFAULT,
					"type": TYPE_INT
				},
				{
					"name": "atlasCoord",
					"usage": PROPERTY_USAGE_DEFAULT,
					"type": TYPE_VECTOR2I
				},
				{
					"name": "alternativeTile",
					"usage": PROPERTY_USAGE_DEFAULT,
					"type": TYPE_INT
				}
			]
		InfoType.TERRAIN:
			return [
				{
					"name": "type",
					"usage": PROPERTY_USAGE_DEFAULT,
					"type": TYPE_INT
				}
			]
		_:
			return []
