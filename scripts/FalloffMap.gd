@tool
class_name FalloffMap
extends Resource
## Creates a heightmap that gets lower as it gets away from the center
# Based off https://github.com/BenjaTK/Gaea/blob/main/addons/gaea/others/falloff_map.gd

@export var visual: Texture2D

enum Shape {SQUARE, CIRCLE, TRIANGLE, PENTAGON, STAR}
@export var shape: Shape = Shape.CIRCLE:
	set(value):
		shape = value
		notify_property_list_changed()
		_generate()

var starSides: int = 5:
	set(value):
		starSides = value
		_generate()
var starAngle: float = .5:
	set(value):
		starAngle = value
		_generate()

@export_range(0., 1., .01) var radius: float = .5:
	set(value):
		radius = value
		_generate()
@export_range(0., 1., .01) var edgeStart: float = 0.:
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
		
@export var flipY: bool = false:
	set(value):
		flipY = value
		_generate()
		
@export var annular: bool = false:
	set(value):
		annular = value
		notify_property_list_changed()
		_generate()
var annularRadius: float = .25:
	set(value):
		annularRadius = value
		_generate()

var map: Dictionary

func _generate() -> void:
	map.clear()
	var image = Image.create(size.x, size.y, false, Image.FORMAT_L8)
	
	for x in size.x:
		for y in size.y:
			var value: float = 0.
			
			var dx: float = 2. * float(x) / float(size.x) - 1.
			var dy: float = 2. * float(y) / float(size.y) - 1.
			# 0 <= dx <= 1 and 0 <= dy <= 1
			
			if flipY:
				dy *= -1
			
			match shape:
				Shape.SQUARE:
					value = box(dx, dy, radius)
				Shape.CIRCLE:
					value = circle(dx, dy, radius)
				Shape.TRIANGLE:
					value = equilateralTriangle(dx, dy, radius)
				Shape.PENTAGON:
					value = pentagon(dx, dy, radius)
				Shape.STAR:
					var m: float = 2. + starAngle * starAngle * (starSides - 2.)
					value = star(dx, dy, radius, starSides, m)
			
			if annular:
				value = abs(value) - annularRadius
			
			if value < edgeStart:
				value = 1.
			elif value > edgeEnd:
				value = 0.
			else:
				value = smoothstep(1., 0., inverse_lerp(edgeStart, edgeEnd, value))
			
			map[Vector2i(x, y)] = value
			
			var color = Color.WHITE
			color.v = value
			image.set_pixel(x, y, color)
	
	visual = ImageTexture.create_from_image(image)

func length(x: float, y: float) -> float:
	return x * x + y * y

func box(x: float, y: float, r: float) -> float:
	x = absf(x) - r
	y = absf(y) - r
	return length(maxf(x, 0.), maxf(y, 0.)) + minf(maxf(x, y), 0.)

func circle(x: float, y: float, r: float) -> float:
	return length(x, y) - r

func equilateralTriangle(x: float, y: float, r: float) -> float:
	const k := sqrt(3.)
	x = absf(x) - r
	y = y + r / k
	if x + k * y > 0.:
		var ox := x
		x = (x - k * y) / 2.
		y = (-k * ox - y) / 2.
	x -= clamp(x, -2. * r, 0.)
	return -length(x, y) * sign(y)

func pentagon(x: float, y: float, r: float) -> float:
	const k := Vector3(.809016994, .587785252, .726542528)
	const k1 := Vector2(-k.x, k.y)
	const k2 := Vector2(k.x, k.y)
	
	x = absf(x)
	var p := Vector2(x, y)
	p -= 2. * min(k1.dot(p), 0.) * k1
	p -= 2. * min(k2.dot(p), 0.) * k2
	p -= Vector2(clamp(p.x, -r * k.z, r * k.z), r)
	
	return p.length() * sign(p.y)

func star(x: float, y: float, r: float, sides: float, angle: float) -> float: # angle=[2,sides]
	var an := PI / float(sides)
	var en := PI / angle
	var acs := Vector2(cos(an), sin(an))
	var ecs := Vector2(cos(en), sin(en))
	
	x = absf(x)
	var p := Vector2(x, y)
	
	var bn := fmod(atan2(p.x, p.y), 2. * an) - an
	p = p.length() * Vector2(cos(bn), abs(sin(bn)))
	
	p -= r * acs
	p += ecs * clampf(-p.dot(ecs), 0., r * acs.y / ecs.y)
	return p.length() * sign(p.x)

func getValue(x: int, y: int) -> float:
	return getValuev(Vector2i(x, y))

func getValuev(pos: Vector2i) -> float:
	return map[pos] if map.has(pos) else 0.

func _get_property_list() -> Array[Dictionary]:
	var properties: Array[Dictionary] = []
	
	var usage = PROPERTY_USAGE_DEFAULT if shape == Shape.STAR else PROPERTY_USAGE_NO_EDITOR
	properties.append({
		"name": "starSides",
		"usage": usage,
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "2,10"
	})
	properties.append({
		"name": "starAngle",
		"usage": usage,
		"type": TYPE_FLOAT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0.,1.,.01"
	})
	
	usage = PROPERTY_USAGE_DEFAULT if annular else PROPERTY_USAGE_NO_EDITOR
	properties.append({
		"name": "annularRadius",
		"usage": usage,
		"type": TYPE_FLOAT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0.,1.,.01"
	})
	
	return properties

func _init() -> void:
	_generate()
