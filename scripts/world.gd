extends Node2D

var lanterns: Array[Vector2] = [Vector2(330,260), Vector2(760,250), Vector2(1040,430), Vector2(510,520)]
var trees: Array[Vector2] = [Vector2(90,120), Vector2(170,155), Vector2(1160,110), Vector2(1110,180), Vector2(1150,590), Vector2(80,600)]
var grass_patches: Array[Vector2] = [Vector2(145,320),Vector2(505,335),Vector2(810,310),Vector2(1090,520),Vector2(235,560),Vector2(720,575)]
var t: float = 0.0
var time_of_day: float = 17.5
var weather: String = "mist"

func set_environment(hour: float, current_weather: String) -> void:
    time_of_day = hour
    weather = current_weather
    queue_redraw()

func _process(delta: float) -> void:
    t += delta
    queue_redraw()

func _draw() -> void:
    _draw_ground_layers()
    _draw_road()
    _draw_stream_and_bridge()
    _draw_village_details()
    _draw_buildings()
    _draw_forest_gate()
    _draw_vegetation()
    _draw_lanterns()
    _draw_foreground_grain()

func _draw_ground_layers() -> void:
    draw_rect(Rect2(0, 0, 1280, 720), Color("26332f"), true)

    var far_mountain := PackedVector2Array([
        Vector2(0, 0), Vector2(1280, 0), Vector2(1280, 118),
        Vector2(1140, 88), Vector2(1000, 108), Vector2(840, 70),
        Vector2(690, 102), Vector2(530, 74), Vector2(360, 112),
        Vector2(190, 76), Vector2(0, 128)
    ])
    draw_colored_polygon(far_mountain, Color("17231f"))

    var near_mountain := PackedVector2Array([
        Vector2(0, 92), Vector2(170, 58), Vector2(330, 115), Vector2(510, 87),
        Vector2(690, 126), Vector2(880, 90), Vector2(1040, 124), Vector2(1280, 84),
        Vector2(1280, 164), Vector2(0, 170)
    ])
    draw_colored_polygon(near_mountain, Color("1d2b25"))

    for i: int in range(13):
        var x: float = 40.0 + float(i) * 102.0
        draw_line(Vector2(x, 176), Vector2(x + 36, 154), Color(0.25, 0.34, 0.29, 0.23), 2.0)

func _draw_road() -> void:
    var road := PackedVector2Array([
        Vector2(0,400), Vector2(280,365), Vector2(610,390), Vector2(970,350), Vector2(1280,380),
        Vector2(1280,500), Vector2(960,470), Vector2(620,500), Vector2(300,460), Vector2(0,510)
    ])
    draw_colored_polygon(road, Color("6d6558"))
    if weather == "drizzle":
        draw_colored_polygon(road, Color(0.16, 0.20, 0.21, 0.22))
        draw_polyline(PackedVector2Array([Vector2(80,458),Vector2(330,423),Vector2(620,458),Vector2(930,421),Vector2(1190,452)]), Color(0.55,0.64,0.66,0.16), 2.0, true)
    draw_polyline(PackedVector2Array([Vector2(0,442),Vector2(300,410),Vector2(620,445),Vector2(970,410),Vector2(1280,440)]), Color("898071"), 3.0)

    for i: int in range(22):
        var x: float = float(i) * 62.0 + 18.0
        var y: float = 425.0 + sin(float(i) * 1.7) * 28.0
        draw_circle(Vector2(x, y), 2.0 + float(i % 3), Color(0.16, 0.15, 0.13, 0.18))

    draw_polyline(PackedVector2Array([Vector2(0,397),Vector2(282,362),Vector2(610,387),Vector2(970,347),Vector2(1280,377)]), Color(0.12,0.14,0.12,0.28), 3.0)
    draw_polyline(PackedVector2Array([Vector2(0,513),Vector2(300,463),Vector2(620,503),Vector2(960,473),Vector2(1280,503)]), Color(0.12,0.14,0.12,0.28), 3.0)

func _draw_stream_and_bridge() -> void:
    draw_rect(Rect2(30,530,410,42), Color("28434a"), true)
    draw_rect(Rect2(30,530,410,4), Color(0.37,0.52,0.54,0.35), true)

    for x: int in range(45, 430, 34):
        var wave_y: float = 542.0 + sin(float(x) * 0.05 + t) * 3.0
        draw_line(Vector2(x, wave_y), Vector2(x + 22, wave_y), Color("5d7b7e"), 2.0)

    for stone in [Vector2(70,558),Vector2(130,538),Vector2(210,559),Vector2(294,540)]:
        draw_circle(stone, 5.0, Color("59615d"))
        draw_circle(stone + Vector2(-1,-1), 3.0, Color(0.48,0.53,0.50,0.45))

    draw_rect(Rect2(360,515,75,70), Color(0,0,0,0.18), true)
    draw_rect(Rect2(356,511,83,68), Color("6b5840"), true)
    for x: int in range(360, 438, 12):
        draw_line(Vector2(x,514), Vector2(x,576), Color("8a7351"), 2.0)
    draw_line(Vector2(356,511), Vector2(439,511), Color("a0835b"), 3.0)

func _draw_village_details() -> void:
    _draw_fence(Vector2(125, 348), 105.0)
    _draw_fence(Vector2(790, 332), 95.0)
    _draw_fence(Vector2(1020, 335), 110.0)

    draw_sign(Vector2(112, 375), "은령마을")
    draw_sign(Vector2(1115, 475), "폐광 2.1km")

    for p in grass_patches:
        for j: int in range(5):
            var off := Vector2(float(j) * 5.0, sin(float(j) * 2.0) * 3.0)
            draw_line(p + off, p + off + Vector2(-2, -10 - float(j % 2) * 3.0), Color("3d5141"), 1.5)

func _draw_buildings() -> void:
    draw_house(Vector2(250,250),Vector2(190,115),"경찰지소",Color("46545a"), "blue")
    draw_house(Vector2(555,205),Vector2(210,135),"마을회관",Color("5d4f46"), "amber")
    draw_house(Vector2(900,235),Vector2(170,105),"여관",Color("544c40"), "warm")
    draw_house(Vector2(910,505),Vector2(210,105),"한상철 자택",Color("443f3a"), "dim")

func _draw_forest_gate() -> void:
    draw_rect(Rect2(1190,280,90,170), Color("192421"), true)
    draw_rect(Rect2(1186, 304, 8, 128), Color("4d3a2b"), true)
    draw_rect(Rect2(1268, 304, 8, 128), Color("4d3a2b"), true)
    draw_rect(Rect2(1180, 300, 102, 8), Color("5f4532"), true)
    draw_line(Vector2(1195, 448), Vector2(1272, 448), Color(0.07,0.09,0.08,0.45), 3.0)
    draw_string(ThemeDB.fallback_font, Vector2(1185,270), "북쪽 숲", HORIZONTAL_ALIGNMENT_LEFT, 100, 18, Color("d7cfb5"))
    draw_string(ThemeDB.fallback_font, Vector2(1200,330), "출입주의", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("bca36a"))

func _draw_vegetation() -> void:
    for p in trees:
        draw_tree(p)

    for i: int in range(16):
        var x: float = 20.0 + float(i) * 82.0
        var y: float = 655.0 + sin(float(i) * 1.3) * 8.0
        draw_circle(Vector2(x, y), 22.0 + float(i % 3) * 4.0, Color(0.08,0.16,0.12,0.48))

func _draw_lanterns() -> void:
    var lamp_power: float = 0.0
    if time_of_day >= 17.8:
        lamp_power = clampf((time_of_day - 17.8) / 1.6, 0.0, 1.0)
    elif time_of_day < 6.3:
        lamp_power = 1.0 - clampf((time_of_day - 5.2) / 1.1, 0.0, 1.0)

    for p in lanterns:
        draw_line(p + Vector2(0,-2), p + Vector2(0,35), Color("2c2925"), 4.0)
        if lamp_power > 0.01:
            var flicker: float = 0.94 + sin(t * 7.0 + p.x * 0.03) * 0.04 + sin(t * 2.1 + p.y) * 0.02
            var glow: float = (18.0 + sin(t * 2.0 + p.x) * 1.4) * flicker
            draw_circle(p, glow * 2.7, Color(1.0,0.62,0.25,0.024 * lamp_power))
            draw_circle(p, glow * 1.75, Color(1.0,0.68,0.34,0.060 * lamp_power))
            draw_circle(p, glow, Color(1.0,0.74,0.40,0.10 * lamp_power))
            draw_circle(p, 5.0, Color(0.91,0.68,0.39, lamp_power))
            draw_circle(p + Vector2(-1,-1), 2.0, Color(1.0,0.91,0.66, lamp_power))
        else:
            draw_circle(p, 4.0, Color("554839"))

func _draw_foreground_grain() -> void:
    for i: int in range(18):
        var x: float = float((i * 73) % 1280)
        var y: float = 600.0 + float((i * 29) % 110)
        draw_circle(Vector2(x,y), 1.5, Color(0.75,0.73,0.64,0.10))

func draw_house(pos: Vector2, size: Vector2, label: String, wall: Color, light_mode: String) -> void:
    draw_rect(Rect2(pos + Vector2(8, 10), size), Color(0,0,0,0.18), true)
    draw_rect(Rect2(pos, size), wall, true)

    var roof := PackedVector2Array([
        pos + Vector2(-12,5),
        pos + Vector2(size.x/2,-38),
        pos + Vector2(size.x+12,5)
    ])
    draw_colored_polygon(roof, Color("2a2928"))
    draw_polyline(PackedVector2Array([roof[0],roof[1],roof[2]]), Color("44403a"), 3.0)

    draw_rect(Rect2(pos + Vector2(size.x*0.42,size.y*0.48), Vector2(34,size.y*0.52)), Color("292725"), true)
    draw_rect(Rect2(pos + Vector2(size.x*0.42 + 4,size.y*0.48 + 8), Vector2(26,5)), Color("594b3b"), true)

    var win_color := Color("b58f59")
    if light_mode == "blue":
        win_color = Color("6f98a2")
    elif light_mode == "dim":
        win_color = Color("6d614b")
    elif light_mode == "warm":
        win_color = Color("c79d61")

    var window_power: float = 0.42
    if time_of_day >= 18.0 or time_of_day < 6.0:
        window_power = 1.0
    elif time_of_day >= 16.5:
        window_power = lerpf(0.42, 1.0, clampf((time_of_day - 16.5) / 1.5, 0.0, 1.0))
    win_color = Color(win_color.r, win_color.g, win_color.b, win_color.a * window_power)

    for wx in [22.0, size.x - 58.0]:
        draw_rect(Rect2(pos + Vector2(wx,35), Vector2(36,28)), Color("2b302e"), true)
        draw_rect(Rect2(pos + Vector2(wx + 3,38), Vector2(30,22)), win_color, true)
        draw_line(pos + Vector2(wx + 18,38), pos + Vector2(wx + 18,60), Color(0.18,0.18,0.16,0.65), 1.5)

    draw_line(pos + Vector2(8,size.y-12), pos + Vector2(size.x-8,size.y-12), wall.lightened(0.12), 2.0)
    draw_string(ThemeDB.fallback_font, pos + Vector2(12,-9), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("ddd6c4"))

func draw_tree(p: Vector2) -> void:
    draw_ellipse(p + Vector2(4,53), Vector2(22,7), Color(0,0,0,0.20))
    draw_line(p, p + Vector2(0,55), Color("514132"), 7.0)
    draw_line(p + Vector2(1,20), p + Vector2(-10,6), Color("514132"), 3.0)
    draw_circle(p + Vector2(0,-10), 25.0, Color("1b3027"))
    draw_circle(p + Vector2(-15,4), 18.0, Color("20382d"))
    draw_circle(p + Vector2(16,6), 19.0, Color("1c3329"))
    draw_circle(p + Vector2(-7,-17), 9.0, Color(0.18,0.28,0.22,0.55))

func _draw_fence(pos: Vector2, length: float) -> void:
    draw_line(pos, pos + Vector2(length, 0), Color("655440"), 3.0)
    draw_line(pos + Vector2(0, 13), pos + Vector2(length, 13), Color("655440"), 3.0)
    var posts: int = int(length / 24.0)
    for i: int in range(posts + 1):
        var px: float = pos.x + float(i) * 24.0
        draw_line(Vector2(px, pos.y - 5), Vector2(px, pos.y + 22), Color("4b3f31"), 4.0)

func draw_sign(pos: Vector2, text: String) -> void:
    draw_line(pos + Vector2(12,22), pos + Vector2(12,47), Color("43382d"), 4.0)
    draw_rect(Rect2(pos, Vector2(92,24)), Color("514334"), true)
    draw_rect(Rect2(pos + Vector2(3,3), Vector2(86,18)), Color("74614a"), true)
    draw_string(ThemeDB.fallback_font, pos + Vector2(8,17), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("ded3ba"))

func draw_ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
    var pts := PackedVector2Array()
    for i: int in range(24):
        var a: float = TAU * float(i) / 24.0
        pts.append(center + Vector2(cos(a) * radius.x, sin(a) * radius.y))
    draw_colored_polygon(pts, color)
