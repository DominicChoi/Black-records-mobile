extends Node2D

const FOREGROUND: Texture2D = preload("res://assets/backgrounds/eunryeong_rpg_foreground_v050.png")
const WORLD_SIZE: Vector2 = Vector2(3200.0, 1600.0)

func _draw() -> void:
    draw_texture_rect(FOREGROUND, Rect2(0.0, 0.0, WORLD_SIZE.x, WORLD_SIZE.y), false)
