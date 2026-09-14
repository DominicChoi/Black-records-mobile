extends Control

@export var player_path: NodePath
@onready var player: Node2D = get_node(player_path)

var quest_code: String = "ARRIVAL"
var focus_id: String = ""
var police_near: bool = false
var pulse: float = 0.0

const WORLD_SIZE := Vector2(1280.0, 720.0)
const POLICE_POS := Vector2(345.0, 355.0)
const FOREST_POS := Vector2(1110.0, 135.0)
const MINE_POS := Vector2(1190.0, 95.0)

func _process(delta: float) -> void:
    pulse = fmod(pulse + delta * 2.3, TAU)
    queue_redraw()

func set_context(new_quest: String, new_focus_id: String, near_police: bool) -> void:
    quest_code = new_quest
    focus_id = new_focus_id
    police_near = near_police

func _map_point(world: Vector2) -> Vector2:
    var pad := Vector2(10.0, 26.0)
    var inner := size - Vector2(20.0, 36.0)
    return pad + Vector2(world.x / WORLD_SIZE.x * inner.x, world.y / WORLD_SIZE.y * inner.y)

func _draw() -> void:
    var full := Rect2(Vector2.ZERO, size)
    draw_rect(full, Color(0.025, 0.035, 0.045, 0.94), true)
    draw_rect(Rect2(2, 2, size.x - 4, size.y - 4), Color(0.43, 0.48, 0.46, 0.62), false, 1.4)

    draw_string(ThemeDB.fallback_font, Vector2(11, 17), "은령마을  ·  MINI MAP", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("ddd5bf"))
    draw_string(ThemeDB.fallback_font, Vector2(size.x - 25, 17), "N", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("d9b96d"))
    draw_line(Vector2(size.x - 18, 22), Vector2(size.x - 18, 31), Color("d9b96d"), 1.5, true)

    var map_rect := Rect2(8, 24, size.x - 16, size.y - 32)
    draw_rect(map_rect, Color("25312f"), true)

    # river / roads
    draw_line(_map_point(Vector2(0, 565)), _map_point(Vector2(1280, 610)), Color(0.19, 0.34, 0.39, 0.90), 7.0, true)
    draw_line(_map_point(Vector2(60, 430)), _map_point(Vector2(1230, 410)), Color("756d60"), 8.0, true)
    draw_line(_map_point(Vector2(920, 420)), _map_point(Vector2(1110, 135)), Color("665f54"), 5.0, true)

    # village blocks
    for world_pos: Vector2 in [Vector2(280, 330), Vector2(510, 330), Vector2(720, 310), Vector2(930, 325), Vector2(1050, 500)]:
        var p := _map_point(world_pos)
        draw_rect(Rect2(p - Vector2(6, 4), Vector2(12, 8)), Color("62564b"), true)

    # landmarks
    _draw_landmark(POLICE_POS, "P", Color("8bb7c7"), police_near)
    _draw_landmark(FOREST_POS, "▲", Color("748b67"), quest_code == "NIGHT_WATCH" or quest_code == "FOLLOW_MAYOR")
    _draw_landmark(MINE_POS, "M", Color("9a846a"), quest_code == "FOLLOW_MAYOR")

    # NPC positions
    for node: Node in get_tree().get_nodes_in_group("npc"):
        if node is Node2D:
            var npc := node as Node2D
            var npc_id := str(npc.get("npc_id"))
            var col := Color("c2a86a") if npc_id == focus_id else Color(0.72, 0.75, 0.70, 0.85)
            var rr := 3.8 if npc_id == focus_id else 2.8
            draw_circle(_map_point(npc.global_position), rr, col)

    # player arrow follows current movement when available
    var pp := _map_point(player.global_position)
    var direction := Vector2.UP
    if player is CharacterBody2D:
        var body := player as CharacterBody2D
        if body.velocity.length() > 5.0:
            direction = body.velocity.normalized()
    var right := direction.rotated(PI * 0.5)
    var arrow := PackedVector2Array([
        pp + direction * 7.0,
        pp - direction * 4.5 + right * 4.2,
        pp - direction * 4.5 - right * 4.2
    ])
    draw_colored_polygon(arrow, Color("f2ddb0"))
    draw_polyline(PackedVector2Array([arrow[0], arrow[1], arrow[2], arrow[0]]), Color("40392f"), 1.0, true)

func _draw_landmark(world: Vector2, label: String, color: Color, active: bool) -> void:
    var p := _map_point(world)
    if active:
        var ring := 6.0 + (sin(pulse) + 1.0) * 2.0
        draw_arc(p, ring, 0.0, TAU, 20, Color(color.r, color.g, color.b, 0.34), 1.5, true)
    draw_circle(p, 4.4 if active else 3.4, color)
    draw_string(ThemeDB.fallback_font, p + Vector2(6, 4), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.90, 0.88, 0.80, 0.92))
