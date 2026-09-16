extends Node2D

@export var background: Texture2D
@export var room_name: String = "실내"
@export var exit_position: Vector2 = Vector2(640, 664)
@export var exit_size: Vector2 = Vector2(220, 70)

func _ready() -> void:
    queue_redraw()

func _draw() -> void:
    if background != null:
        draw_texture_rect(background, Rect2(0, 0, 1280, 720), false)
    var exit_rect := Rect2(exit_position - exit_size * 0.5, exit_size)
    draw_rect(exit_rect, Color(0.03, 0.04, 0.05, 0.34), true)
    draw_rect(exit_rect, Color(0.86, 0.72, 0.43, 0.72), false, 2.0)
    draw_string(ThemeDB.fallback_font, exit_position + Vector2(-38, 5), "나가기", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(0.96, 0.91, 0.78, 0.94))
