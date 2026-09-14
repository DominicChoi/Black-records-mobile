extends CharacterBody2D

@export var speed: float = 185.0
@export var acceleration: float = 920.0
@export var deceleration: float = 1180.0

var mobile_vector: Vector2 = Vector2.ZERO
var facing: Vector2 = Vector2.DOWN
var facing_index: int = 4
var walk_phase: float = 0.0
var idle_phase: float = 0.0
var is_moving: bool = false
var motion_intensity: float = 0.0
var turn_tilt: float = 0.0
var last_move_dir: Vector2 = Vector2.DOWN

const DIAG: float = 0.7071067811865476
const FACE_DIRS: Array[Vector2] = [
    Vector2(0.0, -1.0), Vector2(DIAG, -DIAG), Vector2(1.0, 0.0), Vector2(DIAG, DIAG),
    Vector2(0.0, 1.0), Vector2(-DIAG, DIAG), Vector2(-1.0, 0.0), Vector2(-DIAG, -DIAG)
]

func _physics_process(delta: float) -> void:
    var keys: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
    var input_dir: Vector2 = mobile_vector if mobile_vector.length() > 0.08 else keys
    if input_dir.length() > 1.0:
        input_dir = input_dir.normalized()

    var target_velocity: Vector2 = input_dir * speed
    var rate: float = acceleration if input_dir.length() > 0.05 else deceleration
    velocity = velocity.move_toward(target_velocity, rate * delta)

    var previous_facing: Vector2 = facing
    is_moving = velocity.length() > 7.0
    motion_intensity = move_toward(motion_intensity, clampf(velocity.length() / speed, 0.0, 1.0), delta * 5.0)
    idle_phase += delta

    if input_dir.length() > 0.05:
        facing = input_dir.normalized()
        last_move_dir = facing
        facing_index = _closest_facing(facing)
        var cross: float = previous_facing.x * facing.y - previous_facing.y * facing.x
        turn_tilt = clampf(turn_tilt + cross * 0.9, -1.0, 1.0)
    else:
        facing = last_move_dir

    turn_tilt = move_toward(turn_tilt, 0.0, delta * 4.5)
    if is_moving:
        walk_phase += delta * lerpf(7.8, 11.6, motion_intensity)
    move_and_slide()
    queue_redraw()

func set_mobile_input(v: Vector2) -> void:
    mobile_vector = v

func _closest_facing(v: Vector2) -> int:
    var best: int = 0
    var best_dot: float = -2.0
    for i: int in range(FACE_DIRS.size()):
        var score: float = v.dot(FACE_DIRS[i])
        if score > best_dot:
            best_dot = score
            best = i
    return best

func _draw() -> void:
    var frontness: float = FACE_DIRS[facing_index].y
    var side: float = FACE_DIRS[facing_index].x
    var step_wave: float = sin(walk_phase)
    var step_abs: float = absf(step_wave)
    var bob: float = step_abs * 2.5 * motion_intensity
    if not is_moving:
        bob = sin(idle_phase * 1.55) * 0.45

    var stride: float = step_wave * 6.8 * motion_intensity
    var lean_x: float = turn_tilt * 1.8 * motion_intensity
    _draw_shadow(step_abs)
    _draw_legs(bob, stride, side)
    _draw_coat(bob, side, frontness, lean_x)
    _draw_arms(bob, -stride * 0.76, side, lean_x)
    _draw_bag(bob, side, frontness, stride)
    _draw_head(bob, side, frontness, lean_x)

func _draw_shadow(step_abs: float) -> void:
    var stretch: float = 1.0 + motion_intensity * 0.10
    var lift: float = step_abs * motion_intensity
    draw_ellipse(Vector2(0, 22.5), Vector2(16.8 * stretch, 5.9 - lift * 0.4), Color(0, 0, 0, 0.31 - lift * 0.035))

func _draw_legs(bob: float, stride: float, side: float) -> void:
    var depth: float = 1.8 * side
    var back_foot := Vector2(-5 - stride * 0.50, 26 + bob)
    var front_foot := Vector2(5 + stride * 0.50, 26 + bob)
    draw_line(Vector2(-5 - depth, 9 + bob), back_foot, Color("202831"), 6.5, true)
    draw_line(Vector2(5 - depth, 9 + bob), front_foot, Color("2b3743"), 6.5, true)
    draw_line(back_foot, back_foot + Vector2(signf(back_foot.x) * 3.2, 1.0), Color("14191e"), 7.2, true)
    draw_line(front_foot, front_foot + Vector2(signf(front_foot.x) * 3.2, 1.0), Color("14191e"), 7.2, true)

func _draw_coat(bob: float, side: float, frontness: float, lean_x: float) -> void:
    var shoulder_shift: float = side * 1.8 + lean_x
    var hem_sway: float = sin(walk_phase - 0.65) * 1.3 * motion_intensity
    var coat := PackedVector2Array([
        Vector2(-12 + shoulder_shift, -10 + bob), Vector2(12 + shoulder_shift, -10 + bob),
        Vector2(14 + side * 2.0 + hem_sway, 13 + bob), Vector2(-14 + side * 2.0 + hem_sway, 13 + bob)
    ])
    draw_colored_polygon(coat, Color("344a5e"))
    draw_polyline(PackedVector2Array([coat[0], coat[1], coat[2], coat[3], coat[0]]), Color("17232d"), 1.5, true)
    if frontness > -0.35:
        draw_circle(Vector2(-4 + side * 1.8 + lean_x, bob), 1.3, Color("b6a783"))
        draw_circle(Vector2(4 + side * 1.8 + lean_x, bob), 1.3, Color("b6a783"))
    draw_rect(Rect2(-12 + side * 1.5 + lean_x, 8 + bob, 24, 4), Color("263846"), true)

func _draw_arms(bob: float, swing: float, side: float, lean_x: float) -> void:
    var left_hand := Vector2(-15 + swing * 0.32 + side * 1.5 + lean_x, 9 + bob)
    var right_hand := Vector2(15 - swing * 0.32 + side * 1.5 + lean_x, 9 + bob)
    draw_line(Vector2(-10 + side * 1.4 + lean_x, -5 + bob), left_hand, Color("2e4355"), 5.5, true)
    draw_line(Vector2(10 + side * 1.4 + lean_x, -5 + bob), right_hand, Color("3a5063"), 5.5, true)
    draw_circle(left_hand, 2.4, Color("cf9f7a"))
    draw_circle(right_hand, 2.4, Color("cf9f7a"))

func _draw_bag(bob: float, side: float, frontness: float, stride: float) -> void:
    var bag_side: float = 1.0 if side >= 0.0 else -1.0
    if absf(side) < 0.15:
        bag_side = 1.0
    var sway: float = -stride * 0.13
    var bx: float = 10.0 * bag_side + side * 2.0 + sway
    draw_line(Vector2(-8 * bag_side, -8 + bob), Vector2(7 * bag_side + sway, 9 + bob), Color("b08c5b"), 2.0, true)
    draw_rect(Rect2(bx - 5, 4 + bob, 10, 10), Color("765536"), true)
    draw_rect(Rect2(bx - 4, 5 + bob, 8, 3), Color("96704a"), true)

func _draw_head(bob: float, side: float, frontness: float, lean_x: float) -> void:
    var head_pos := Vector2(side * 1.4 + lean_x * 0.65, -20 + bob)
    draw_circle(head_pos, 10.0, Color("d4a37e"))
    draw_arc(head_pos + Vector2(-1, -2), 9.2, PI * 1.04, PI * 1.98, 14, Color("1b1d20"), 5.0, true)
    if frontness > -0.55:
        var blink: bool = fmod(idle_phase, 4.6) > 4.47 and not is_moving
        var eye_y: float = head_pos.y - 1.0 + maxf(frontness, 0.0) * 1.3
        var eye_gap: float = 3.4 if absf(side) < 0.6 else 1.8
        var eye_shift: float = side * 2.2
        if blink:
            draw_line(Vector2(head_pos.x - eye_gap - 1.0 + eye_shift, eye_y), Vector2(head_pos.x - eye_gap + 1.0 + eye_shift, eye_y), Color("15181b"), 1.0, true)
        else:
            draw_circle(Vector2(head_pos.x - eye_gap + eye_shift, eye_y), 1.15, Color("15181b"))
            if absf(side) < 0.78:
                draw_circle(Vector2(head_pos.x + eye_gap + eye_shift, eye_y), 1.15, Color("15181b"))

func draw_ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
    var pts := PackedVector2Array()
    for i: int in range(28):
        var a: float = TAU * float(i) / 28.0
        pts.append(center + Vector2(cos(a) * radius.x, sin(a) * radius.y))
    draw_colored_polygon(pts, color)
