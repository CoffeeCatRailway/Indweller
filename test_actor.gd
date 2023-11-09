extends Sprite2D

@export var speed: float
@export var tilemap: TileMap

func _process(delta):
	var mousePos := tilemap.local_to_map(get_global_mouse_position())
	if (Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		BetterTerrain.set_cell(tilemap, 0, mousePos, 0)

func _physics_process(delta: float) -> void:
	var move: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	global_position += move * delta * speed
