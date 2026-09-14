extends Control

signal changed(value: Vector2)

@export var radius := 62.0
var pointer_id := -1
var knob := Vector2.ZERO

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_STOP
    set_process_input(true)
    queue_redraw()

func _gui_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed and pointer_id == -1:
            pointer_id = event.index
            update_knob(event.position)
        elif not event.pressed and event.index == pointer_id:
            pointer_id = -1
            knob = Vector2.ZERO
            changed.emit(Vector2.ZERO)
            queue_redraw()
    elif event is InputEventScreenDrag and event.index == pointer_id:
        update_knob(event.position)
    elif event is InputEventMouseButton:
        if event.pressed:
            pointer_id = 999
            update_knob(event.position)
        else:
            pointer_id = -1
            knob = Vector2.ZERO
            changed.emit(Vector2.ZERO)
            queue_redraw()
    elif event is InputEventMouseMotion and pointer_id == 999:
        update_knob(event.position)

func update_knob(local: Vector2) -> void:
    var center := size * 0.5
    var d := local - center
    knob = d.limit_length(radius)
    changed.emit(knob / radius)
    queue_redraw()

func _draw() -> void:
    var c := size * 0.5
    draw_circle(c,radius,Color(0.08,0.10,0.12,0.42))
    draw_circle(c,32,Color(0.7,0.76,0.8,0.22))
    draw_circle(c+knob,26,Color(0.82,0.85,0.88,0.66))
