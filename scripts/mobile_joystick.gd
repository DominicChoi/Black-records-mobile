extends Control

signal changed(value: Vector2)

@export var radius: float = 62.0
@export var deadzone: float = 0.16
var pointer_id: int = -1
var knob: Vector2 = Vector2.ZERO
var output: Vector2 = Vector2.ZERO
var active: bool = false

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_STOP
    set_process_input(true)
    queue_redraw()

func _gui_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        var touch := event as InputEventScreenTouch
        if touch.pressed and pointer_id == -1:
            pointer_id = touch.index
            active = true
            update_knob(touch.position)
        elif not touch.pressed and touch.index == pointer_id:
            _release()
    elif event is InputEventScreenDrag:
        var drag := event as InputEventScreenDrag
        if drag.index == pointer_id:
            update_knob(drag.position)
    elif event is InputEventMouseButton:
        var mouse_button := event as InputEventMouseButton
        if mouse_button.pressed:
            pointer_id = 999
            active = true
            update_knob(mouse_button.position)
        elif pointer_id == 999:
            _release()
    elif event is InputEventMouseMotion and pointer_id == 999:
        var mouse_motion := event as InputEventMouseMotion
        update_knob(mouse_motion.position)

func _release() -> void:
    pointer_id = -1
    knob = Vector2.ZERO
    output = Vector2.ZERO
    active = false
    changed.emit(Vector2.ZERO)
    queue_redraw()

func update_knob(local: Vector2) -> void:
    var center := size * 0.5
    var d := local - center
    knob = d.limit_length(radius)
    var raw := knob / radius
    var length := raw.length()
    if length <= deadzone:
        output = Vector2.ZERO
    else:
        var scaled := (length - deadzone) / (1.0 - deadzone)
        output = raw.normalized() * clampf(scaled, 0.0, 1.0)
    changed.emit(output)
    queue_redraw()

func _draw() -> void:
    var c := size * 0.5
    var base_alpha := 0.54 if active else 0.34
    draw_circle(c, radius + 8.0, Color(0.01, 0.02, 0.03, base_alpha * 0.55))
    draw_circle(c, radius, Color(0.08, 0.10, 0.12, base_alpha))
    draw_arc(c, radius - 1.0, 0.0, TAU, 40, Color(0.65, 0.72, 0.76, 0.26 if active else 0.16), 1.5, true)

    for dir: Vector2 in [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]:
        draw_line(c + dir * 42.0, c + dir * 51.0, Color(0.72, 0.77, 0.79, 0.28), 2.0, true)

    draw_circle(c, radius * deadzone, Color(0.70, 0.76, 0.80, 0.08))
    var knob_pos := c + knob
    draw_circle(knob_pos, 29.0, Color(0.02, 0.03, 0.04, 0.33))
    draw_circle(knob_pos, 25.0, Color(0.82, 0.85, 0.88, 0.76 if active else 0.58))
    draw_circle(knob_pos - Vector2(5, 6), 5.0, Color(1.0, 1.0, 1.0, 0.10))
