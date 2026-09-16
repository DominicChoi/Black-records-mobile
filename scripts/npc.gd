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
var dialogue_variant: int = 0
var story_quest: String = "ARRIVAL"
var story_flags: Dictionary = {}
var current_time: float = 17.5
var schedule_target: Vector2 = Vector2.ZERO
var schedule_label: String = ""

const MAYOR_SHEET: Texture2D = preload("res://assets/sprites/mayor_sheet.png")
const REPORTER_SHEET: Texture2D = preload("res://assets/sprites/reporter_sheet.png")
const KEEPER_SHEET: Texture2D = preload("res://assets/sprites/keeper_sheet.png")
const FRAME_W: float = 64.0
const FRAME_H: float = 80.0

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
    var distance: float = global_position.distance_to(target)
    if distance < 10.0:
        if wait_timer <= 0.0:
            wait_timer = _wait_duration_for_schedule()
        _idle_facing_for_schedule()
    elif wait_timer <= 0.0:
        facing = global_position.direction_to(target)
        velocity = facing * _current_move_speed()
        is_moving = true
        walk_phase += delta * 7.0
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
            schedule_target = Vector2(2540, 352)
            schedule_label = "북쪽 숲 입구 이동"
        else:
            schedule_target = Vector2(1835, 1205)
            schedule_label = "이장집 앞"
    elif current_time >= 19.0:
        schedule_target = Vector2(1120, 930)
        schedule_label = "광장 주변"
    elif current_time >= 12.0:
        schedule_target = Vector2(1450, 980)
        schedule_label = "중앙 순찰"
    else:
        schedule_target = Vector2(1835, 1205)
        schedule_label = "이장집 앞"

func _schedule_reporter() -> void:
    if current_time >= 21.0 or current_time < 1.0:
        schedule_target = Vector2(2085, 885)
        schedule_label = "북쪽 갈림길 감시"
    elif current_time >= 18.0:
        schedule_target = Vector2(720, 915)
        schedule_label = "경찰지소 주변"
    elif current_time >= 12.0:
        schedule_target = Vector2(1210, 980)
        schedule_label = "마을 광장 취재"
    else:
        schedule_target = Vector2(1030, 990)
        schedule_label = "기록 정리"

func _schedule_keeper() -> void:
    if current_time >= 20.0 or current_time < 6.0:
        schedule_target = Vector2(2860, 642)
        schedule_label = "폐광 입구 확인"
    elif current_time >= 15.0:
        schedule_target = Vector2(2220, 1090)
        schedule_label = "동부 창고 점검"
    else:
        schedule_target = Vector2(2880, 640)
        schedule_label = "관리소 대기"

func _wait_duration_for_schedule() -> float:
    if npc_id == "mayor" and schedule_label == "북쪽 숲 입구 이동":
        return 0.4
    if npc_id == "reporter":
        return 2.2
    if npc_id == "keeper":
        return 2.8
    return 1.4

func _current_move_speed() -> float:
    if npc_id == "mayor" and schedule_label == "북쪽 숲 입구 이동":
        return 60.0
    if npc_id == "keeper":
        return 36.0
    return move_speed

func _idle_facing_for_schedule() -> void:
    if npc_id == "mayor" and schedule_label == "북쪽 숲 입구 이동":
        facing = Vector2.UP
    elif npc_id == "reporter" and schedule_label == "북쪽 갈림길 감시":
        facing = Vector2.UP
    elif npc_id == "keeper" and schedule_label == "폐광 입구 확인":
        facing = Vector2.LEFT

func get_dialogue(time_of_day: float, quest: String = "", flags: Dictionary = {}) -> String:
    talk_cooldown = 0.8
    dialogue_variant = (dialogue_variant + 1) % 3
    var q: String = quest if not quest.is_empty() else story_quest
    var f: Dictionary = flags if not flags.is_empty() else story_flags

    if npc_id == "mayor":
        if q == "FOLLOW_MAYOR":
            return "한상철: 광장을 지나 북쪽 숲 입구까지 가는 길은 길지만, 오늘 밤 누군가 따라오는 느낌이 드는군."
        if time_of_day >= 21.7 and bool(f.get("mayor_follow_unlocked", false)):
            return "한상철: 북쪽 숲 초입까지만 가도 충분하오. 폐광까지는 더 이상 묻지 마시오."
        if time_of_day >= 19.0:
            var mayor_evening := [
                "한상철: 마을이 커 보여도 핵심은 북쪽 숲과 폐광으로 이어지는 옛길이오.",
                "한상철: 해가 지면 회관 문부터 확인하오. 오래된 기록을 찾는 사람이 가끔 있어서 말이오.",
                "한상철: 여관 뒤편 길은 밤이면 안개가 빨리 차오르니 북쪽으로 갈 생각은 접으시오."
            ]
            return mayor_evening[dialogue_variant]
        var mayor_day := [
            "한상철: 서쪽 수호당, 남쪽 호수, 동쪽 폐광… 은령마을은 보기보다 넓은 곳이오.",
            "한상철: 낮에는 회관에 들렀다가 광장을 한 바퀴 도는 게 내 일과요.",
            "한상철: 경찰지소의 옛 장부는 마을 기록과 날짜가 맞지 않는 부분이 있소."
        ]
        return mayor_day[dialogue_variant]

    if npc_id == "reporter":
        if q == "FOLLOW_MAYOR":
            return "정우진: 광장 조명과 숲 안개를 엄폐로 쓰세요. 지금처럼 넓은 맵에선 시야 관리가 더 중요합니다."
        if q == "NIGHT_WATCH" and time_of_day >= 21.0:
            return "정우진: 한상철이 북쪽 숲 입구로 갑니다. 거리가 길어졌으니 도중에 시야를 놓치지 마세요."
        if bool(f.get("met_keeper", false)):
            return "정우진: 장도식이 말한 동부 창고와 폐광 입구를 연결해 보면, 밤마다 누군가 동선을 반복한 흔적이 있어요."
        if time_of_day >= 18.0:
            var reporter_evening := [
                "정우진: 이 마을은 중심 광장만 보면 좁아 보이지만, 실제론 숲·호수·폐광까지 이어진 구조예요.",
                "정우진: 경찰지소 불이 꺼지기 전에 사건 장부를 한 번 더 봐야겠어요.",
                "정우진: 여관 투숙객 명부와 마을회관 행사 기록을 맞춰 보면 빈 날짜가 반복돼요."
            ]
            return reporter_evening[dialogue_variant]
        var reporter_day := [
            "정우진: 공식 기록은 작지만, 현장의 지형은 훨씬 넓습니다. 이 차이를 조사해야 해요.",
            "정우진: 낮에는 광장에서 주민 동선을 기록하고 있어요. 같은 사람이 같은 길을 반복하더군요.",
            "정우진: 실내 기록도 현장 증거예요. 경찰지소와 회관부터 들어가 보죠."
        ]
        return reporter_day[dialogue_variant]

    if npc_id == "keeper":
        if q == "FOLLOW_MAYOR":
            return "장도식: 동쪽 창고를 지나 폐광 진입로로 가는 길은 자갈이 많아. 뛰면 바로 들켜."
        if time_of_day >= 20.0:
            var keeper_night := [
                "장도식: 오늘도 폐광 입구 쪽 레일 근처에 새 발자국이 있어. 북쪽 숲에서 내려온 흔적 같군.",
                "장도식: 밤 순찰은 창고에서 시작해 폐광 입구에서 끝내. 그런데 요즘 내 것 아닌 발자국이 섞여 있어.",
                "장도식: 비가 온 뒤에도 지워지지 않는 자국이 있어. 레일 안쪽은 직접 확인해 봐야 해."
            ]
            return keeper_night[dialogue_variant]
        if bool(f.get("met_mayor", false)):
            return "장도식: 이장은 숲 입구만 말하지만, 실제로는 숲-창고-폐광이 하나의 동선처럼 이어져 있어."
        return "장도식: 여기서 동쪽은 폐광, 서쪽은 마을 중심, 남쪽은 호수 쪽이야. 밤엔 방향 감각을 잃기 쉽지."

    return "%s: 오늘도 마을 분위기가 심상치 않네요." % display_name

func get_schedule_label() -> String:
    return schedule_label

func _sprite_texture() -> Texture2D:
    if npc_id == "mayor":
        return MAYOR_SHEET
    if npc_id == "reporter":
        return REPORTER_SHEET
    return KEEPER_SHEET

func _direction_row() -> int:
    if absf(facing.x) > absf(facing.y):
        return 2 if facing.x > 0.0 else 1
    return 0 if facing.y >= 0.0 else 3

func _frame_col() -> int:
    if not is_moving:
        return 0
    return int(floor(walk_phase)) % 4

func _draw() -> void:
    var tex: Texture2D = _sprite_texture()
    var row: int = _direction_row()
    var col: int = _frame_col()
    var src: Rect2 = Rect2(float(col) * FRAME_W, float(row) * FRAME_H, FRAME_W, FRAME_H)
    var stride: float = sin(walk_phase * PI)
    var bob: float = -1.4 * absf(stride) if is_moving else 0.0
    var sway: float = stride * 0.8 if is_moving else 0.0
    var shadow_scale: float = 0.94 if is_moving else 1.0

    draw_set_transform(Vector2(sway * 0.2, 18.0), 0.0, Vector2(shadow_scale, 1.0))
    draw_circle(Vector2.ZERO, 14.0, Color(0.01, 0.015, 0.02, 0.20))
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

    draw_texture_rect_region(tex, Rect2(-32.0 + sway, -53.0 + bob, FRAME_W, FRAME_H), src)
    _draw_nameplate()

func _draw_nameplate() -> void:
    var alpha: float = 0.95 if talk_cooldown > 0.0 else 0.74
    var label: String = "%s · %s" % [display_name, role]
    var fnt: Font = ThemeDB.fallback_font
    var text_size: int = 12
    var width: float = fnt.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, text_size).x + 12.0
    draw_rect(Rect2(-width * 0.5, -57.0, width, 18.0), Color(0.025, 0.035, 0.04, alpha), true)
    draw_string(fnt, Vector2(-width * 0.5 + 6.0, -43.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1, text_size, Color(0.94, 0.91, 0.82, alpha))
