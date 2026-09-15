extends Node2D

@export var background_path: String = "res://assets/backgrounds/eunryeong_village_night_jrpg.jpg"
@export var design_size: Vector2 = Vector2(1920.0,1080.0)
var texture: Texture2D

func _ready() -> void:
    texture = load(background_path) as Texture2D
    queue_redraw()

func _draw() -> void:
    if texture == null:
        return
    draw_texture_rect(texture, Rect2(Vector2.ZERO, design_size), false, Color.WHITE)

func set_environment(_hour: float, _weather: String) -> void:
    # Weather/night overlays remain controlled by the existing UI/weather system.
    pass
