extends CharacterBody2D

@export var npc_id: String = "npc"
@export var display_name: String = "주민"
@export var role: String = "주민"
@export var tint: Color = Color("6f7780")
@export var routine_points: Array[Vector2] = []
@export var move_speed: float = 45.0

var routine_index: int = 0
var idle_phase: float = 0.0
var walk_phase: float = 0.0
var talk_cooldown: float = 0.0
var facing: Vector2 = Vector2.DOWN
var is_moving: bool = false
var wait_timer: float = 0.0
var story_quest: String = "ARRIVAL"
var story_flags: Dictionary = {}
var current_time: float = 17.5
var schedule_target: Vector2 = Vector2.ZERO
var schedule_label: String = ""

func _ready() -> void:
    add_to_group("npc")
    schedule_target = global_position

func set_story_context(quest: String, flags: Dictionary, time_of_day: float) -> void:
    story_quest = quest
    story_flags = flags
    current_time = time_of_day
    _update_schedule_target()

func _physics_process(delta: float) -> void:
    idle_phase += delta
    talk_cooldown = maxf(0.0, talk_cooldown - delta)
    wait_timer = maxf(0.0, wait_timer - delta)
    velocity = Vector2.ZERO
    is_moving = false

    _update_schedule_target()
    var target: Vector2 = schedule_target
    var d: float = global_position.distance_to(target)

    if d < 10.0:
        if wait_timer <= 0.0:
            wait_timer = _wait_duration_for_schedule()
        _idle_facing_for_schedule()
    elif wait_timer <= 0.0:
        facing = global_position.direction_to(target)
        velocity = facing * _current_move_speed()
        is_moving = true
        walk_phase += delta * 7.2
        move_and_slide()

    queue_redraw()

func _update_schedule_target() -> void:
    if npc_id == "mayor":
        _schedule_mayor()
    elif npc_id == "reporter":
        _schedule_reporter()
    elif npc_id == "keeper":
        _schedule_keeper()
    elif routine_points.size() > 0:
        schedule_target = routine_points[routine_index % routine_points.size()]
        schedule_label = "순찰"

func _schedule_mayor() -> void:
    if current_time >= 21.7 or current_time < 1.0:
        if bool(story_flags.get("mayor_follow_unlocked", false)):
            schedule_target = Vector2(1175, 255)
            schedule_label = "북쪽 길 이동"
        else:
            schedule_target = Vector2(1010, 430)
            schedule_label = "이장집 앞"
    elif current_time >= 19.0:
        schedule_target = Vector2(940, 405)
        schedule_label = "마을회관 주변"
    elif current_time >= 12.0:
        schedule_target = Vector2(710, 350)
        schedule_label = "마을 순찰"
    else:
        schedule_target = Vector2(1010, 430)
        schedule_label = "이장집 앞"

func _schedule_reporter() -> void:
    if current_time >= 21.0 or current_time < 1.0:
        schedule_target = Vector2(625, 410)
        schedule_label = "북쪽 길 감시"
    elif current_time >= 18.0:
        schedule_target = Vector2(420, 390)
        schedule_label = "경찰지소 주변"
    elif current_time >= 12.0:
        schedule_target = Vector2(835, 430)
        schedule_label = "주민 취재"
    else:
        schedule_target = Vector2(700, 470)
        schedule_label = "기록 정리"

func _schedule_keeper() -> void:
    if current_time >= 20.0 or current_time < 6.0:
        schedule_target = Vector2(1130, 315)
        schedule_label = "폐광 관리도로 확인"
    elif current_time >= 15.0:
        schedule_target = Vector2(1190, 500)
        schedule_label = "장비 창고 점검"
    else:
        schedule_target = Vector2(1090, 545)
        schedule_label = "관리소 대기"

func _wait_duration_for_schedule() -> float:
    if npc_id == "mayor" and schedule_label == "북쪽 길 이동":
        return 0.4
    if npc_id == "reporter":
        return 2.2
    if npc_id == "keeper":
        return 3.0
    return 1.4

func _current_move_speed() -> float:
    if npc_id == "mayor" and schedule_label == "북쪽 길 이동":
        return 58.0
    if npc_id == "keeper":
        return 34.0
    return move_speed

func _idle_facing_for_schedule() -> void:
    if npc_id == "mayor" and schedule_label == "북쪽 길 이동":
        facing = Vector2.UP
    elif npc_id == "reporter" and schedule_label == "북쪽 길 감시":
        facing = Vector2.UP
    elif npc_id == "keeper" and schedule_label == "폐광 관리도로 확인":
        facing = Vector2.LEFT

func get_dialogue(time_of_day: float, quest: String = "", flags: Dictionary = {}) -> String:
    talk_cooldown = 0.8
    var q: String = quest if not quest.is_empty() else story_quest
    var f: Dictionary = flags if not flags.is_empty() else story_flags

    if npc_id == "mayor":
        if q == "FOLLOW_MAYOR":
            return "한상철: …누가 따라오는 건가? 바람 소리겠지."
        if time_of_day >= 21.7 and bool(f.get("mayor_follow_unlocked", false)):
            return "한상철: 오늘은 늦었습니다. 북쪽 길에는 절대 가지 마십시오."
        if bool(f.get("met_reporter", false)):
            return "한상철: 정우진 기자 말은 믿지 마십시오. 오래된 사고를 괜히 들쑤시고 있습니다."
        if time_of_day >= 19.0:
            return "한상철: 해가 지면 마을 밖으로 나가지 마십시오. 안개가 갑자기 짙어집니다."
        return "한상철: 외지인이 오래 머물 곳은 아닙니다. 필요한 일이 끝나면 내려가십시오."

    if npc_id == "reporter":
        if q == "FOLLOW_MAYOR":
            return "정우진: 지금입니다. 한상철과 거리를 두고 따라가세요. 시야에서 놓치지만 마십시오."
        if q == "NIGHT_WATCH" and time_of_day >= 21.0:
            return "정우진: 이장은 곧 북쪽 길로 움직일 겁니다. 가로등이 끝나는 지점부터는 몸을 숨기세요."
        if bool(f.get("met_keeper", false)):
            return "정우진: 장도식이 폐광 관리도로에 발자국이 남는다고 했죠? 이장 동선과 겹치는지 봐야 합니다."
        if time_of_day >= 18.0:
            return "정우진: 공식 기록에는 7명이라고 적혀 있습니다. 그런데 당시 사진에는 여덟 번째 사람이 있어요."
        return "정우진: 공식 기록과 주민들 기억이 서로 안 맞습니다. 서기태 이름부터 확인해 보죠."

    if npc_id == "keeper":
        if q == "FOLLOW_MAYOR":
            return "장도식: 북쪽 샛길로 갔다면 폐광 쪽이야. 오래된 철제 표지판을 지나면 발소리를 죽여."
        if time_of_day >= 20.0:
            return "장도식: 밤마다 관리도로 자물쇠 위치가 조금씩 달라져. 누군가 건드린다는 뜻이지."
        if bool(f.get("met_mayor", false)):
            return "장도식: 한상철은 폐광이 완전히 막혔다고 하지? 그건 반만 맞는 말이야. 옛 관리도로가 남아 있어."
        return "장도식: 폐광은 닫혔어. 그래도 옛 관리도로엔 아직 발자국이 남지."

    return "%s: 요즘 마을 분위기가 좀 이상하지요." % display_name

func get_schedule_label() -> String:
    return schedule_label

func _draw() -> void:
    var bob: float = absf(sin(walk_phase)) * 1.8 if is_moving else sin(idle_phase * 1.9) * 0.45
    var stride: float = sin(walk_phase) * 4.5 if is_moving else 0.0
    var side: float = signf(facing.x) if absf(facing.x) > 0.25 else 0.0
    var frontness: float = facing.y
    _draw_shadow()
    _draw_legs(bob, stride)
    _draw_body(bob, side)
    _draw_head(bob, side, frontness)
    _draw_identity_detail(bob)
    _draw_nameplate()

func _draw_shadow() -> void:
    draw_ellipse(Vector2(0, 20), Vector2(13.5, 5.0), Color(0, 0, 0, 0.24))

func _draw_legs(bob: float, stride: float) -> void:
    draw_line(Vector2(-4, 8 + bob), Vector2(-5 - stride * 0.40, 23 + bob), Color("292d33"), 5.5, true)
    draw_line(Vector2(4, 8 + bob), Vector2(5 + stride * 0.40, 23 + bob), Color("34383e"), 5.5, true)

func _draw_body(bob: float, side: float) -> void:
    var body: PackedVector2Array = PackedVector2Array([
        Vector2(-10 + side, -10 + bob), Vector2(10 + side, -10 + bob),
        Vector2(12 + side, 12 + bob), Vector2(-12 + side, 12 + bob)
    ])
    draw_colored_polygon(body, tint)
    draw_polyline(PackedVector2Array([body[0], body[1], body[2], body[3], body[0]]), tint.darkened(0.35), 1.2, true)
    draw_line(Vector2(-9 + side, -4 + bob), Vector2(-13 + side, 8 + bob), tint.darkened(0.10), 4.5, true)
    draw_line(Vector2(9 + side, -4 + bob), Vector2(13 + side, 8 + bob), tint.lightened(0.06), 4.5, true)

func _draw_head(bob: float, side: float, frontness: float) -> void:
    var p: Vector2 = Vector2(side * 1.2, -18 + bob)
    draw_circle(p, 8.7, Color("cda17e"))
    var hair: Color = Color("272522")
    if npc_id == "reporter":
        hair = Color("1b2024")
    if npc_id == "keeper":
        hair = Color("6d675e")
    draw_arc(p + Vector2(0, -1), 8.0, PI * 1.03, PI * 1.98, 12, hair, 4.0, true)
    if frontness > -0.5:
        var eye_shift: float = side * 1.8
        draw_circle(p + Vector2(-2.6 + eye_shift, -0.3), 0.95, Color("17191b"))
        if absf(side) < 0.8:
            draw_circle(p + Vector2(2.6 + eye_shift, -0.3), 0.95, Color("17191b"))
    if npc_id == "keeper":
        draw_line(p + Vector2(-4, 5), p + Vector2(4, 5), Color("5b554e"), 2.2, true)

func _draw_identity_detail(bob: float) -> void:
    if npc_id == "mayor":
        draw_rect(Rect2(-8, -7 + bob, 16, 3), Color("5b4632"), true)
        draw_circle(Vector2(0, 3 + bob), 1.8, Color("c9b46e"))
    elif npc_id == "reporter":
        draw_line(Vector2(-7, -6 + bob), Vector2(7, 7 + bob), Color("8a6b45"), 1.8, true)
        draw_rect(Rect2(6, 4 + bob, 7, 7), Color("2b3137"), true)
    elif npc_id == "keeper":
        draw_rect(Rect2(-11, -9 + bob, 22, 4), Color("4d483f"), true)
        draw_line(Vector2(-8, 7 + bob), Vector2(8, 7 + bob), Color("b29353"), 2.0, true)

func _draw_nameplate() -> void:
    var alpha: float = 0.92 if talk_cooldown > 0.0 else 0.72
    var label: String = "%s · %s" % [display_name, role]
    var font: Font = ThemeDB.fallback_font
    var size: int = 12
    var width: float = font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x + 12.0
    draw_rect(Rect2(-width * 0.5, -43, width, 17), Color(0.04, 0.05, 0.06, alpha), true)
    draw_string(font, Vector2(-width * 0.5 + 6, -30), label, HORIZONTAL_ALIGNMENT_LEFT, -1, size, Color(0.92, 0.90, 0.82, alpha))

func draw_ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
    var pts: PackedVector2Array = PackedVector2Array()
    for i: int in range(24):
        var a: float = TAU * float(i) / 24.0
        pts.append(center + Vector2(cos(a) * radius.x, sin(a) * radius.y))
    draw_colored_polygon(pts, color)
