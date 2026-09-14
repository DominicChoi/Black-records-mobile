extends CharacterBody2D

@export var speed := 185.0
var mobile_vector := Vector2.ZERO
var facing := Vector2.DOWN
var facing_index := 4
var walk_phase := 0.0
var idle_phase := 0.0
var is_moving := false

const FACE_DIRS := [
    Vector2(0,-1), Vector2(1,-1).normalized(), Vector2(1,0), Vector2(1,1).normalized(),
    Vector2(0,1), Vector2(-1,1).normalized(), Vector2(-1,0), Vector2(-1,-1).normalized()
]

func _physics_process(delta: float) -> void:
    var keys := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    var dir := mobile_vector if mobile_vector.length() > 0.08 else keys
    if dir.length() > 1.0:
        dir = dir.normalized()
    velocity = dir * speed
    is_moving = dir.length() > 0.05
    idle_phase += delta
    if is_moving:
        facing = dir.normalized()
        facing_index = _closest_facing(facing)
        walk_phase += delta * 10.5
    else:
        walk_phase = 0.0
    move_and_slide()
    queue_redraw()

func set_mobile_input(v: Vector2) -> void:
    mobile_vector = v

func _closest_facing(v: Vector2) -> int:
    var best := 0
    var best_dot := -2.0
    for i in FACE_DIRS.size():
        var score := v.dot(FACE_DIRS[i])
        if score > best_dot:
            best_dot = score
            best = i
    return best

func _draw() -> void:
    var frontness := FACE_DIRS[facing_index].y
    var side := FACE_DIRS[facing_index].x
    var bob := abs(sin(walk_phase)) * 2.3 if is_moving else sin(idle_phase * 1.6) * 0.35
    var stride := sin(walk_phase) * 6.2 if is_moving else 0.0
    var arm_swing := -stride * 0.72
    var body_y := bob

    _draw_shadow()
    _draw_legs(body_y, stride, side)
    _draw_coat(body_y, side, frontness)
    _draw_arms(body_y, arm_swing, side)
    _draw_bag(body_y, side, frontness)
    _draw_head(body_y, side, frontness)

func _draw_shadow() -> void:
    var stretch := 1.0 + (0.08 if is_moving else 0.0)
    draw_ellipse(Vector2(0,22), Vector2(16.5 * stretch, 6.0), Color(0,0,0,0.30))

func _draw_legs(bob: float, stride: float, side: float) -> void:
    var depth := 1.8 * side
    var back_leg := Vector2(-5-depth, 9+bob)
    var front_leg := Vector2(5-depth, 9+bob)
    var back_foot := Vector2(-5-stride*0.48, 26+bob)
    var front_foot := Vector2(5+stride*0.48, 26+bob)
    draw_line(back_leg, back_foot, Color("202831"), 6.5, true)
    draw_line(front_leg, front_foot, Color("2a3541"), 6.5, true)
    draw_line(back_foot, back_foot+Vector2(sign(-5-stride*0.48)*2.0,1.0), Color("161b20"), 7.0, true)
    draw_line(front_foot, front_foot+Vector2(sign(5+stride*0.48)*2.0,1.0), Color("161b20"), 7.0, true)

func _draw_coat(bob: float, side: float, frontness: float) -> void:
    var shoulder_shift := side * 1.8
    var coat := PackedVector2Array([
        Vector2(-12+shoulder_shift,-10+bob), Vector2(12+shoulder_shift,-10+bob),
        Vector2(14+side*2,13+bob), Vector2(-14+side*2,13+bob)
    ])
    draw_colored_polygon(coat, Color("344a5e"))
    draw_polyline(PackedVector2Array([coat[0],coat[1],coat[2],coat[3],coat[0]]), Color("17232d"), 1.5, true)
    draw_line(Vector2(0+side*1.8,-8+bob),Vector2(0+side*1.2,11+bob),Color("4d6579"),1.3)
    if frontness > -0.35:
        draw_circle(Vector2(-4+side*1.8,0+bob),1.3,Color("b6a783"))
        draw_circle(Vector2(4+side*1.8,0+bob),1.3,Color("b6a783"))
    draw_rect(Rect2(-12+side*1.5,8+bob,24,4),Color("263846"),true)

func _draw_arms(bob: float, swing: float, side: float) -> void:
    var left_start := Vector2(-10+side*1.4,-5+bob)
    var right_start := Vector2(10+side*1.4,-5+bob)
    draw_line(left_start, Vector2(-15+swing*0.30+side*1.5,9+bob), Color("2e4355"), 5.5, true)
    draw_line(right_start, Vector2(15-swing*0.30+side*1.5,9+bob), Color("3a5063"), 5.5, true)
    draw_circle(Vector2(-15+swing*0.30+side*1.5,9+bob),2.4,Color("cf9f7a"))
    draw_circle(Vector2(15-swing*0.30+side*1.5,9+bob),2.4,Color("cf9f7a"))

func _draw_bag(bob: float, side: float, frontness: float) -> void:
    var bag_side := 1.0 if side >= 0.0 else -1.0
    if abs(side) < 0.15:
        bag_side = 1.0
    var strap_color := Color("b08c5b")
    if frontness < -0.3:
        draw_line(Vector2(-8,-8+bob),Vector2(8,9+bob),strap_color,2.0,true)
    else:
        draw_line(Vector2(-8*bag_side,-8+bob),Vector2(7*bag_side,9+bob),strap_color,2.0,true)
    var bx := 10.0 * bag_side + side*2.0
    draw_rect(Rect2(bx-5,4+bob,10,10),Color("765536"),true)
    draw_rect(Rect2(bx-4,5+bob,8,3),Color("96704a"),true)

func _draw_head(bob: float, side: float, frontness: float) -> void:
    var head_pos := Vector2(side*1.4,-20+bob)
    draw_circle(head_pos,10.0,Color("d4a37e"))
    # hair silhouette gives a readable character shape even at phone scale
    draw_arc(head_pos+Vector2(-1,-2),9.2,PI*1.04,PI*1.98,14,Color("1b1d20"),5.0,true)
    draw_polygon(PackedVector2Array([
        head_pos+Vector2(-8,-5),head_pos+Vector2(-3,-11),head_pos+Vector2(5,-10),head_pos+Vector2(9,-4),head_pos+Vector2(5,-6),head_pos+Vector2(-2,-5)
    ]),PackedColorArray([Color("202226")]))
    if frontness > -0.55:
        var eye_y := head_pos.y - 1.0 + max(frontness,0.0)*1.3
        var eye_gap := 3.4 if abs(side) < 0.6 else 1.8
        var eye_shift := side*2.2
        draw_circle(Vector2(head_pos.x-eye_gap+eye_shift,eye_y),1.15,Color("15181b"))
        if abs(side) < 0.78:
            draw_circle(Vector2(head_pos.x+eye_gap+eye_shift,eye_y),1.15,Color("15181b"))
        draw_line(Vector2(head_pos.x+eye_shift-1.5,head_pos.y+4),Vector2(head_pos.x+eye_shift+1.5,head_pos.y+4),Color("8f5f4f"),1.0)
    else:
        draw_arc(head_pos+Vector2(0,1),7.5,0.15,PI-0.15,10,Color("191b1e"),3.2,true)

func draw_ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
    var pts := PackedVector2Array()
    for i in 28:
        var a := TAU * float(i) / 28.0
        pts.append(center + Vector2(cos(a)*radius.x, sin(a)*radius.y))
    draw_colored_polygon(pts, color)
