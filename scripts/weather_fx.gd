extends Control

var time_of_day: float = 17.5
var weather: String = "mist"
var quest: String = "ARRIVAL"
var t: float = 0.0
var transition: float = 1.0
var previous_weather: String = "mist"

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    set_process(true)

func set_environment(hour: float, next_weather: String, next_quest: String = "") -> void:
    time_of_day = hour
    if not next_quest.is_empty():
        quest = next_quest
    if weather != next_weather:
        previous_weather = weather
        weather = next_weather
        transition = 0.0
    queue_redraw()

func _process(delta: float) -> void:
    t += delta
    transition = minf(1.0, transition + delta * 0.16)
    queue_redraw()

func _draw() -> void:
    var night_amount: float = _night_amount(time_of_day)
    _draw_haze(night_amount)
    if weather == "mist":
        _draw_mist(transition, night_amount)
    elif weather == "drizzle":
        _draw_mist(0.48, night_amount)
        _draw_drizzle(transition)
        _draw_wet_glints(transition, night_amount)
    elif weather == "overcast":
        _draw_cloud_veil(transition, night_amount)
    _draw_pursuit_visibility(night_amount)
    _draw_vignette(night_amount)

func _night_amount(hour: float) -> float:
    if hour >= 19.0:
        return clampf((hour - 19.0) / 3.0, 0.0, 1.0)
    if hour < 5.5:
        return 1.0
    if hour < 7.0:
        return 1.0 - clampf((hour - 5.5) / 1.5, 0.0, 1.0)
    return 0.0

func _draw_haze(night_amount: float) -> void:
    var dusk_amount: float = 0.0
    if time_of_day >= 17.0 and time_of_day < 20.5:
        dusk_amount = sin(clampf((time_of_day - 17.0) / 3.5, 0.0, 1.0) * PI)
    if dusk_amount > 0.01:
        draw_rect(Rect2(0, 0, size.x, size.y), Color(0.34, 0.20, 0.16, 0.055 * dusk_amount), true)
    if night_amount > 0.01:
        draw_rect(Rect2(0, 0, size.x, size.y), Color(0.035, 0.065, 0.12, 0.075 * night_amount), true)

func _draw_mist(alpha_scale: float, night_amount: float) -> void:
    var base_alpha: float = lerpf(0.035, 0.075, night_amount) * alpha_scale
    for i: int in range(8):
        var speed: float = 8.0 + float(i % 3) * 3.5
        var x: float = fmod(float(i) * 181.0 + t * speed, size.x + 360.0) - 260.0
        var y: float = 110.0 + float(i) * 72.0 + sin(t * 0.22 + float(i)) * 16.0
        var radius := Vector2(155.0 + float(i % 2) * 40.0, 28.0 + float(i % 3) * 7.0)
        _draw_soft_ellipse(Vector2(x, y), radius, Color(0.72, 0.78, 0.77, base_alpha))

func _draw_cloud_veil(alpha_scale: float, night_amount: float) -> void:
    var a: float = (0.045 + night_amount * 0.03) * alpha_scale
    draw_rect(Rect2(0, 0, size.x, size.y * 0.42), Color(0.32, 0.36, 0.38, a), true)
    for i: int in range(5):
        var x: float = fmod(float(i) * 295.0 + t * 3.0, size.x + 320.0) - 180.0
        _draw_soft_ellipse(Vector2(x, 90 + i * 18), Vector2(190, 44), Color(0.48, 0.51, 0.52, a * 0.8))

func _draw_drizzle(alpha_scale: float) -> void:
    var a: float = 0.18 * alpha_scale
    for i: int in range(46):
        var seed_x: float = float((i * 97) % 1280)
        var fall: float = fmod(t * (145.0 + float(i % 5) * 14.0) + float(i * 53), 790.0)
        var x: float = fmod(seed_x - fall * 0.16, size.x + 30.0)
        var y: float = fall - 35.0
        draw_line(Vector2(x, y), Vector2(x - 5.0, y + 14.0), Color(0.66, 0.77, 0.86, a), 1.0, true)

func _draw_wet_glints(alpha_scale: float, night_amount: float) -> void:
    if night_amount < 0.08:
        return
    var pulse: float = 0.72 + sin(t * 1.7) * 0.10
    for i: int in range(7):
        var x: float = 120.0 + float(i) * 175.0
        var y: float = 604.0 + sin(float(i) * 1.4) * 18.0
        draw_line(Vector2(x, y), Vector2(x + 42.0, y - 3.0), Color(0.56, 0.70, 0.78, 0.055 * alpha_scale * night_amount * pulse), 2.0, true)

func _draw_pursuit_visibility(night_amount: float) -> void:
    if quest != "FOLLOW_MAYOR" or night_amount < 0.12:
        return
    var danger_alpha: float = clampf(night_amount * 0.10, 0.0, 0.10)
    if weather == "drizzle":
        danger_alpha += 0.025
    elif weather == "mist":
        danger_alpha += 0.04
    draw_rect(Rect2(0, 0, size.x, size.y), Color(0.025, 0.035, 0.055, danger_alpha), true)
    var breath: float = 0.5 + 0.5 * sin(t * 1.2)
    draw_rect(Rect2(0, size.y - 92.0, size.x, 92.0), Color(0.01, 0.015, 0.025, 0.025 + breath * 0.018), true)

func _draw_vignette(night_amount: float) -> void:
    var edge_alpha: float = 0.035 + night_amount * 0.10
    if quest == "FOLLOW_MAYOR":
        edge_alpha += 0.035 * night_amount
    draw_rect(Rect2(0, 0, size.x, 32), Color(0, 0, 0, edge_alpha), true)
    draw_rect(Rect2(0, size.y - 40, size.x, 40), Color(0, 0, 0, edge_alpha * 1.25), true)
    draw_rect(Rect2(0, 0, 30, size.y), Color(0, 0, 0, edge_alpha), true)
    draw_rect(Rect2(size.x - 30, 0, 30, size.y), Color(0, 0, 0, edge_alpha), true)

func _draw_soft_ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
    for layer: int in range(4, 0, -1):
        var scale_factor: float = float(layer) / 4.0
        var layer_color := Color(color.r, color.g, color.b, color.a * (0.30 / scale_factor))
        var pts := PackedVector2Array()
        for i: int in range(28):
            var a: float = TAU * float(i) / 28.0
            pts.append(center + Vector2(cos(a) * radius.x * scale_factor, sin(a) * radius.y * scale_factor))
        draw_colored_polygon(pts, layer_color)
