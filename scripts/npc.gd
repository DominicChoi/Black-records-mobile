extends CharacterBody2D

@export var npc_id := "npc"
@export var display_name := "주민"
@export var role := "주민"
@export var tint := Color("6f7780")
@export var routine_points: Array[Vector2] = []
@export var move_speed := 45.0

var routine_index := 0
var idle_phase := 0.0
var walk_phase := 0.0
var talk_cooldown := 0.0
var facing := Vector2.DOWN
var is_moving := false

func _ready() -> void:
    add_to_group("npc")

func _physics_process(delta: float) -> void:
    idle_phase += delta
    talk_cooldown = max(0.0, talk_cooldown-delta)
    velocity = Vector2.ZERO
    is_moving = false
    if routine_points.size() > 0:
        var target := routine_points[routine_index]
        var d := global_position.distance_to(target)
        if d < 8.0:
            routine_index = (routine_index + 1) % routine_points.size()
        else:
            facing = global_position.direction_to(target)
            velocity = facing * move_speed
            is_moving = true
            walk_phase += delta * 7.0
            move_and_slide()
    queue_redraw()

func get_dialogue(time_of_day: float) -> String:
    talk_cooldown = 0.8
    if npc_id == "mayor":
        if time_of_day >= 21.0:
            return "한상철: 이 시간엔 돌아다니지 않는 게 좋습니다. 북쪽 길은 특히요."
        return "한상철: 외지인이 오래 머물 곳은 아닙니다. 필요한 일이 끝나면 내려가십시오."
    if npc_id == "reporter":
        if time_of_day >= 20.0:
            return "정우진: 이장은 밤 10시 전후로 혼자 북쪽 길을 씁니다. 너무 가까이 붙진 마세요."
        return "정우진: 공식 기록과 주민들 기억이 서로 안 맞습니다. 서기태 이름부터 확인해 보죠."
    if npc_id == "keeper":
        return "장도식: 폐광은 닫혔어. 그래도 옛 관리도로엔 아직 발자국이 남지."
    return "%s: 요즘 마을 분위기가 좀 이상하지요." % display_name

func _draw() -> void:
    var bob := abs(sin(walk_phase))*1.8 if is_moving else sin(idle_phase*1.9)*0.45
    var stride := sin(walk_phase)*4.5 if is_moving else 0.0
    var side := sign(facing.x) if abs(facing.x) > 0.25 else 0.0
    var frontness := facing.y
    _draw_shadow()
    _draw_legs(bob,stride)
    _draw_body(bob,side)
    _draw_head(bob,side,frontness)
    _draw_identity_detail(bob)
    _draw_nameplate()

func _draw_shadow() -> void:
    draw_ellipse(Vector2(0,20),Vector2(13.5,5.0),Color(0,0,0,0.24))

func _draw_legs(bob: float, stride: float) -> void:
    draw_line(Vector2(-4,8+bob),Vector2(-5-stride*0.40,23+bob),Color("292d33"),5.5,true)
    draw_line(Vector2(4,8+bob),Vector2(5+stride*0.40,23+bob),Color("34383e"),5.5,true)

func _draw_body(bob: float, side: float) -> void:
    var body := PackedVector2Array([Vector2(-10+side,-10+bob),Vector2(10+side,-10+bob),Vector2(12+side,12+bob),Vector2(-12+side,12+bob)])
    draw_colored_polygon(body,tint)
    draw_polyline(PackedVector2Array([body[0],body[1],body[2],body[3],body[0]]),tint.darkened(0.35),1.2,true)
    draw_line(Vector2(-9+side,-4+bob),Vector2(-13+side,8+bob),tint.darkened(0.10),4.5,true)
    draw_line(Vector2(9+side,-4+bob),Vector2(13+side,8+bob),tint.lightened(0.06),4.5,true)

func _draw_head(bob: float, side: float, frontness: float) -> void:
    var p := Vector2(side*1.2,-18+bob)
    draw_circle(p,8.7,Color("cda17e"))
    var hair := Color("272522")
    if npc_id == "reporter": hair = Color("1b2024")
    if npc_id == "keeper": hair = Color("6d675e")
    draw_arc(p+Vector2(0,-1),8.0,PI*1.03,PI*1.98,12,hair,4.0,true)
    if frontness > -0.5:
        var eye_shift := side*1.8
        draw_circle(p+Vector2(-2.6+eye_shift,-0.3),0.95,Color("17191b"))
        if abs(side) < 0.8:
            draw_circle(p+Vector2(2.6+eye_shift,-0.3),0.95,Color("17191b"))
    if npc_id == "keeper":
        draw_line(p+Vector2(-4,5),p+Vector2(4,5),Color("5b554e"),2.2,true)

func _draw_identity_detail(bob: float) -> void:
    if npc_id == "mayor":
        draw_rect(Rect2(-8,-7+bob,16,3),Color("5b4632"),true)
        draw_circle(Vector2(0,3+bob),1.8,Color("c9b46e"))
    elif npc_id == "reporter":
        draw_line(Vector2(-7,-6+bob),Vector2(7,7+bob),Color("8a6b45"),1.8,true)
        draw_rect(Rect2(6,4+bob,7,7),Color("2b3137"),true)
    elif npc_id == "keeper":
        draw_rect(Rect2(-11,-9+bob,22,4),Color("4d483f"),true)
        draw_line(Vector2(-8,7+bob),Vector2(8,7+bob),Color("b29353"),2.0,true)

func _draw_nameplate() -> void:
    var alpha := 0.92 if talk_cooldown > 0.0 else 0.72
    var label := "%s · %s" % [display_name,role]
    var font := ThemeDB.fallback_font
    var size := 12
    var width := font.get_string_size(label,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x + 12.0
    draw_rect(Rect2(-width*0.5,-43,width,17),Color(0.04,0.05,0.06,alpha),true)
    draw_string(font,Vector2(-width*0.5+6,-30),label,HORIZONTAL_ALIGNMENT_LEFT,-1,size,Color(0.92,0.90,0.82,alpha))

func draw_ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
    var pts := PackedVector2Array()
    for i in 24:
        var a := TAU * float(i) / 24.0
        pts.append(center + Vector2(cos(a)*radius.x, sin(a)*radius.y))
    draw_colored_polygon(pts, color)
