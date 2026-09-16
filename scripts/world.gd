extends Node2D

const BACKGROUND: Texture2D = preload("res://assets/backgrounds/eunryeong_rpg_overworld_v050.png")
const WORLD_SIZE: Vector2 = Vector2(3200.0, 1600.0)

var time_of_day: float = 17.5
var weather: String = "mist"
var t: float = 0.0
var lanterns: Array[Vector2] = [
    Vector2(702.0, 780.0),
    Vector2(1130.0, 810.0),
    Vector2(1466.0, 795.0),
    Vector2(1868.0, 1170.0),
    Vector2(2864.0, 640.0),
    Vector2(314.0, 672.0),
    Vector2(1102.0, 1180.0),
    Vector2(2220.0, 1070.0)
]

func set_environment(hour: float, current_weather: String) -> void:
    time_of_day = hour
    weather = current_weather
    queue_redraw()

func _process(delta: float) -> void:
    t += delta
    queue_redraw()

func _draw() -> void:
    draw_texture_rect(BACKGROUND, Rect2(0.0, 0.0, WORLD_SIZE.x, WORLD_SIZE.y), false)
    _draw_time_tint()
    _draw_lantern_glow()
    _draw_water_shimmer()
    _draw_mist()

func _draw_time_tint() -> void:
    var tint: Color = Color(0.0, 0.0, 0.0, 0.0)
    if time_of_day >= 22.0 or time_of_day < 5.0:
        tint = Color(0.02, 0.06, 0.15, 0.28)
    elif time_of_day >= 19.0:
        var a: float = clampf((time_of_day - 19.0) / 3.0, 0.0, 1.0)
        tint = Color(0.03, 0.07, 0.14, 0.10 + a * 0.18)
    elif time_of_day >= 17.0:
        tint = Color(0.22, 0.10, 0.03, 0.05)
    if weather == "mist":
        tint = Color(tint.r + 0.02, tint.g + 0.03, tint.b + 0.04, tint.a + 0.04)
    draw_rect(Rect2(0.0, 0.0, WORLD_SIZE.x, WORLD_SIZE.y), tint, true)

func _draw_lantern_glow() -> void:
    var power: float = 0.22
    if time_of_day >= 18.0 or time_of_day < 6.0:
        power = 1.0
    for p: Vector2 in lanterns:
        var flicker: float = 0.94 + sin(t * 6.2 + p.x * 0.007) * 0.06
        draw_circle(p, 60.0, Color(1.0, 0.58, 0.20, 0.015 * power * flicker))
        draw_circle(p, 34.0, Color(1.0, 0.68, 0.30, 0.035 * power * flicker))
        draw_circle(p, 10.0, Color(1.0, 0.78, 0.42, 0.09 * power * flicker))

func _draw_water_shimmer() -> void:
    for i: int in range(32):
        var x: float = 40.0 + float(i) * 36.0
        var y: float = 1290.0 + sin(t * 1.3 + float(i) * 0.5) * 10.0
        draw_line(Vector2(x, y), Vector2(x + 28.0, y), Color(0.54, 0.76, 0.84, 0.18), 1.8, true)

func _draw_mist() -> void:
    if weather != "mist":
        return
    for i: int in range(9):
        var cx: float = 1980.0 + float(i) * 95.0 + sin(t * 0.45 + float(i)) * 24.0
        var cy: float = 210.0 + float(i % 3) * 56.0
        draw_circle(Vector2(cx, cy), 64.0, Color(0.72, 0.82, 0.84, 0.024))
