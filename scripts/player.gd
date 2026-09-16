extends CharacterBody2D

@export var speed: float = 185.0
@export var acceleration: float = 980.0
@export var deceleration: float = 1320.0

var mobile_vector: Vector2 = Vector2.ZERO
var facing: Vector2 = Vector2.DOWN
var walk_phase: float = 0.0
var is_moving: bool = false
var motion_intensity: float = 0.0
var interact_timer: float = 0.0
var step_side: float = 0.0

const SPRITE_SHEET: Texture2D = preload("res://assets/sprites/player_sheet.png")
const FRAME_W: float = 64.0
const FRAME_H: float = 80.0

func _physics_process(delta: float) -> void:
    interact_timer = maxf(0.0, interact_timer - delta)
    var keys: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
    var input_dir: Vector2 = mobile_vector if mobile_vector.length() > 0.08 else keys
    if input_dir.length() > 1.0:
        input_dir = input_dir.normalized()

    var target_velocity: Vector2 = input_dir * speed
    var rate: float = acceleration if input_dir.length() > 0.05 else deceleration
    velocity = velocity.move_toward(target_velocity, rate * delta)
    is_moving = velocity.length() > 8.0 and interact_timer <= 0.0

    var target_intensity: float = clampf(velocity.length() / speed, 0.0, 1.0) if is_moving else 0.0
    motion_intensity = move_toward(motion_intensity, target_intensity, delta * 7.5)

    if input_dir.length() > 0.05 and interact_timer <= 0.0:
        facing = input_dir.normalized()
    if is_moving:
        walk_phase += delta * lerpf(6.2, 9.4, motion_intensity)
        step_side = sin(walk_phase * PI) * 1.25 * motion_intensity
    else:
        step_side = move_toward(step_side, 0.0, delta * 12.0)

    if interact_timer > 0.0:
        velocity = velocity.move_toward(Vector2.ZERO, deceleration * 1.8 * delta)

    move_and_slide()
    queue_redraw()

func set_mobile_input(v: Vector2) -> void:
    mobile_vector = v

func play_interact_pose() -> void:
    interact_timer = 0.34
    walk_phase = 0.0
    queue_redraw()

func _direction_row() -> int:
    if absf(facing.x) > absf(facing.y):
        return 2 if facing.x > 0.0 else 1
    return 0 if facing.y >= 0.0 else 3

func _frame_col() -> int:
    if interact_timer > 0.0:
        return 1
    if not is_moving:
        return 0
    return int(floor(walk_phase)) % 4

func _draw() -> void:
    var row: int = _direction_row()
    var col: int = _frame_col()
    var src: Rect2 = Rect2(float(col) * FRAME_W, float(row) * FRAME_H, FRAME_W, FRAME_H)
    var stride: float = sin(walk_phase * PI)
    var bob: float = -1.8 * absf(stride) * motion_intensity
    var lean: float = clampf(velocity.x / maxf(speed, 1.0), -1.0, 1.0) * 1.3
    var interact_dip: float = 2.0 * sin(clampf(interact_timer / 0.34, 0.0, 1.0) * PI)

    var shadow_scale: float = 1.0 - absf(stride) * 0.08 * motion_intensity
    draw_set_transform(Vector2(step_side * 0.25, 18.0), 0.0, Vector2(shadow_scale, 1.0))
    draw_circle(Vector2.ZERO, 15.5, Color(0.01, 0.015, 0.02, 0.23))
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

    var dest: Rect2 = Rect2(-32.0 + step_side + lean, -53.0 + bob + interact_dip, FRAME_W, FRAME_H)
    draw_texture_rect_region(SPRITE_SHEET, dest, src)

    if interact_timer > 0.0:
        var alpha: float = sin(clampf(interact_timer / 0.34, 0.0, 1.0) * PI) * 0.48
        var p: Vector2 = facing.normalized() * 29.0 + Vector2(0.0, -13.0)
        draw_arc(p, 7.0, -0.9, 0.9, 10, Color(0.98, 0.84, 0.48, alpha), 2.0, true)
