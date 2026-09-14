extends Node2D

var t: float = 0.0

func _process(delta: float) -> void:
    t += delta
    queue_redraw()

func _draw() -> void:
    _draw_shell()
    _draw_floor()
    _draw_windows_and_light()
    _draw_service_desk()
    _draw_archive_shelves()
    _draw_evidence_board()
    _draw_furniture()
    _draw_exit()
    _draw_dust()

func _draw_shell() -> void:
    draw_rect(Rect2(0,0,1280,720), Color("151819"), true)
    draw_rect(Rect2(110,80,1060,560), Color(0,0,0,0.28), true)
    draw_rect(Rect2(105,75,1060,560), Color("454039"), true)
    draw_rect(Rect2(135,105,1010,510), Color("6a6257"), true)
    draw_rect(Rect2(135,105,1010,92), Color("595248"), true)
    draw_line(Vector2(135,197), Vector2(1145,197), Color("837563"), 3.0)

func _draw_floor() -> void:
    draw_rect(Rect2(145, 330, 990, 275), Color("655b50"), true)
    for y: int in range(344, 606, 31):
        draw_line(Vector2(145,y), Vector2(1135,y), Color("514a42"), 2.0)
    for x: int in range(160, 1136, 80):
        draw_line(Vector2(x,330), Vector2(x + 32,605), Color(0.25,0.23,0.21,0.18), 1.0)

    draw_rect(Rect2(505, 468, 270, 96), Color("514737"), true)
    draw_rect(Rect2(514, 477, 252, 78), Color("78654a"), true)
    draw_rect(Rect2(528, 490, 224, 52), Color("5b4d3b"), false, 2.0)

func _draw_windows_and_light() -> void:
    _draw_window(Vector2(300, 125))
    _draw_window(Vector2(865, 125))

    var pulse: float = 0.03 + (sin(t * 1.7) + 1.0) * 0.012
    draw_circle(Vector2(640, 155), 74.0, Color(1.0,0.82,0.55,pulse))
    draw_line(Vector2(640,105), Vector2(640,128), Color("3b342d"), 3.0)
    draw_circle(Vector2(640,136), 9.0, Color("d8aa62"))
    draw_circle(Vector2(638,134), 3.0, Color("ffe2a3"))

func _draw_service_desk() -> void:
    draw_rect(Rect2(315,251,650,92), Color(0,0,0,0.18), true)
    draw_rect(Rect2(315,245,650,92), Color("3e342c"), true)
    draw_rect(Rect2(335,225,610,28), Color("78654f"), true)
    draw_line(Vector2(335,253), Vector2(945,253), Color("987d5d"), 2.0)

    draw_string(ThemeDB.fallback_font, Vector2(530,210), "은령 경찰지소", HORIZONTAL_ALIGNMENT_LEFT, -1, 25, Color("ddd5c2"))

    # desk props
    draw_rect(Rect2(380, 210, 42, 15), Color("2b3130"), true)
    draw_line(Vector2(388,212), Vector2(388,225), Color("8b9a8f"), 1.0)
    draw_rect(Rect2(825, 209, 56, 16), Color("b9ae91"), true)
    draw_line(Vector2(832,214), Vector2(870,214), Color("746d5e"), 1.0)
    draw_circle(Vector2(914,216), 10.0, Color("414746"))
    draw_circle(Vector2(914,216), 5.0, Color("80745f"))

    for x in [380.0, 520.0, 665.0, 810.0]:
        draw_rect(Rect2(x, 286, 76, 40), Color("342c26"), false, 2.0)
        draw_circle(Vector2(x + 62,306), 2.0, Color("b4986d"))

func _draw_archive_shelves() -> void:
    _draw_shelf(Vector2(170,165), true)
    _draw_shelf(Vector2(1010,165), false)

func _draw_shelf(pos: Vector2, left_side: bool) -> void:
    draw_rect(Rect2(pos + Vector2(5,7), Vector2(95,300)), Color(0,0,0,0.20), true)
    draw_rect(Rect2(pos, Vector2(95,300)), Color("332d28"), true)
    draw_rect(Rect2(pos + Vector2(6,6), Vector2(83,288)), Color("403831"), true)

    for y: int in range(int(pos.y) + 24, int(pos.y) + 282, 45):
        draw_line(Vector2(pos.x + 8,y), Vector2(pos.x + 87,y), Color("8c7656"), 5.0)
        for j: int in range(5):
            var file_x: float = pos.x + 12.0 + float(j) * 14.0
            var file_h: float = 24.0 + float((j + y) % 3) * 4.0
            var c: Color = Color("765f48") if (j + y) % 2 == 0 else Color("53615e")
            draw_rect(Rect2(file_x, float(y) - file_h, 9, file_h - 4.0), c, true)

    var plate_text: String = "사건기록" if left_side else "보관자료"
    draw_rect(Rect2(pos + Vector2(16,-24), Vector2(63,18)), Color("514537"), true)
    draw_string(ThemeDB.fallback_font, pos + Vector2(22,-11), plate_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("d8ccb2"))

func _draw_evidence_board() -> void:
    draw_rect(Rect2(426,411,440,135), Color(0,0,0,0.18), true)
    draw_rect(Rect2(420,405,440,135), Color("2b3935"), true)
    draw_rect(Rect2(430,415,420,115), Color("33443f"), true)
    draw_string(ThemeDB.fallback_font, Vector2(445,438), "1996년 폐광 사고 기록", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("d7d1c4"))

    _draw_note(Vector2(455, 452), Vector2(86,52), Color("d7caa6"), "작업일지")
    _draw_note(Vector2(725, 446), Vector2(92,58), Color("beb7a4"), "현장사진")
    _draw_note(Vector2(585, 472), Vector2(100,44), Color("c9c2ae"), "인원명단")

    draw_line(Vector2(498,478), Vector2(632,494), Color("9d5f55"), 2.0)
    draw_line(Vector2(769,475), Vector2(640,494), Color("9d5f55"), 2.0)
    draw_circle(Vector2(640,494), 4.0, Color("b56255"))

func _draw_note(pos: Vector2, size: Vector2, color: Color, label: String) -> void:
    draw_rect(Rect2(pos, size), color, true)
    draw_circle(pos + Vector2(size.x * 0.5, 4), 2.2, Color("a45e51"))
    draw_string(ThemeDB.fallback_font, pos + Vector2(8,19), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("4d463b"))
    draw_line(pos + Vector2(8,28), pos + Vector2(size.x-8,28), Color(0.28,0.26,0.23,0.35), 1.0)

func _draw_furniture() -> void:
    # waiting bench
    draw_rect(Rect2(260,470,120,18), Color("604b39"), true)
    draw_rect(Rect2(268,488,8,38), Color("3e3329"), true)
    draw_rect(Rect2(364,488,8,38), Color("3e3329"), true)

    # chair near desk
    draw_rect(Rect2(900,382,52,44), Color("4a3c30"), false, 4.0)
    draw_line(Vector2(908,426), Vector2(904,458), Color("3a3028"), 4.0)
    draw_line(Vector2(944,426), Vector2(948,458), Color("3a3028"), 4.0)

    # coat rack
    draw_line(Vector2(1080,410), Vector2(1080,515), Color("3d342c"), 5.0)
    draw_line(Vector2(1062,430), Vector2(1098,430), Color("3d342c"), 3.0)
    draw_line(Vector2(1080,515), Vector2(1065,530), Color("3d342c"), 3.0)
    draw_line(Vector2(1080,515), Vector2(1095,530), Color("3d342c"), 3.0)
    draw_polygon(PackedVector2Array([Vector2(1064,436),Vector2(1096,436),Vector2(1104,485),Vector2(1056,485)]), PackedColorArray([Color("35434a")]))

    # wall clock
    draw_circle(Vector2(1040,125), 20.0, Color("342f2a"))
    draw_circle(Vector2(1040,125), 16.0, Color("d6cfbd"))
    draw_line(Vector2(1040,125), Vector2(1040,115), Color("393631"), 2.0)
    draw_line(Vector2(1040,125), Vector2(1048,129), Color("393631"), 2.0)

func _draw_exit() -> void:
    draw_rect(Rect2(595,590,90,50), Color(0,0,0,0.20), true)
    draw_rect(Rect2(590,585,100,55), Color("232a2b"), true)
    draw_rect(Rect2(602,592,76,42), Color("30393a"), true)
    draw_string(ThemeDB.fallback_font, Vector2(615,620), "출구", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("d5ccb6"))
    draw_circle(Vector2(670,612), 3.0, Color("b8955f"))

func _draw_window(pos: Vector2) -> void:
    draw_rect(Rect2(pos, Vector2(116,62)), Color("353a38"), true)
    draw_rect(Rect2(pos + Vector2(5,5), Vector2(106,52)), Color("718184"), true)
    draw_line(pos + Vector2(58,5), pos + Vector2(58,57), Color("393e3d"), 3.0)
    draw_line(pos + Vector2(5,31), pos + Vector2(111,31), Color("393e3d"), 3.0)
    draw_polygon(PackedVector2Array([pos+Vector2(5,42),pos+Vector2(40,24),pos+Vector2(76,39),pos+Vector2(111,20),pos+Vector2(111,57),pos+Vector2(5,57)]), PackedColorArray([Color("374744")]))

func _draw_dust() -> void:
    for i: int in range(9):
        var x: float = 240.0 + float((i * 97) % 780)
        var y: float = 160.0 + float((i * 53) % 330) + sin(t * 0.45 + float(i)) * 5.0
        draw_circle(Vector2(x,y), 1.2, Color(0.92,0.87,0.73,0.16))
