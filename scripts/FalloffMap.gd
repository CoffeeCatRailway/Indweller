@tool
class_name FalloffMap
extends Resource
## Creates a heightmap that gets lower as it gets away from the center
# Based off https://github.com/BenjaTK/Gaea/blob/main/addons/gaea/others/falloff_map.gd

@export var visual: Texture2D

enum Shape {SQUARE, CIRCLE, TRIANGLE}
@export var shape: Shape = Shape.CIRCLE:
	set(value):
		shape = value
		_generate()
@export var donut: bool = true:
	set(value):
		donut = value
		_generate()

@export_range(0., 1., .01) var edgeStart: float = .05:
	set(value):
		edgeStart = value
		_generate()
@export_range(0., 1., .01) var edgeEnd: float = .5:
	set(value):
		edgeEnd = value
		_generate()
		
@export var size: Vector2i = Vector2i(48, 48):
	set(value):
		size = abs(value)
		_generate()

var map: Dictionary

func _generate() -> void:
	map.clear()
	var image = Image.create(size.x, size.y, false, Image.FORMAT_L8)
	
	for x in size.x:
		for y in size.y:
			var value: float
			
			var dx: float = 2. * float(x) / float(size.x) - 1.
			var dy: float = 2. * float(y) / float(size.y) - 1.
			# 0 <= dx <= 1 and 0 <= dy <= 1
			
			match shape:
				Shape.SQUARE:
					value = maxf(absf(dx), absf(dy))
				Shape.CIRCLE:
					value = (dx * dx + dy * dy) / 2.
			
			if value < edgeStart:
				value = 0. if donut else 1.
			elif value > edgeEnd:
				value = 0.
			else:
				value = smoothstep(1., 0., inverse_lerp(edgeStart, edgeEnd, value))
				#value = smoothstep(0., 1., inverse_lerp(edgeStart, edgeEnd, value))
			
			map[Vector2i(x, y)] = value
			
			var color = Color.WHITE
			color.v = value
			image.set_pixel(x, y, color)
	
	visual = ImageTexture.create_from_image(image)
	
func getValue(x: int, y: int) -> float:
	return getValuev(Vector2i(x, y))

func getValuev(pos: Vector2i) -> float:
	return map[pos] if map.has(pos) else 0.

func _init() -> void:
	_generate()
