extends Control

@export var player_path: NodePath
@onready var player: Node2D = get_node_or_null(player_path) as Node2D

var quest_code: String = "ARRIVAL"
var focus_id: String = ""
var police_near: bool = false
var pulse: float = 0.0

const WORLD_SIZE: Vector2 = Vector2(3200.0, 1600.0)
const VIEW_SIZE: Vector2 = Vector2(1280.0, 720.0)
const POLICE_POS: Vector2 = Vector2(710.0, 855.0)
const FOREST_POS: Vector2 = Vector2(2540.0, 352.0)
const MINE_POS: Vector2 = Vector2(2860.0, 640.0)
const SHRINE_POS: Vector2 = Vector2(330.0, 650.0)
const LAKE_POS: Vector2 = Vector2(780.0, 1260.0)
const HOME_POS: Vector2 = Vector2(1835.0, 1205.0)

func _process(delta: float) -> void:
	pulse = fmod(pulse + delta * 2.3, TAU)
	if not is_instance_valid(player):
		player = get_node_or_null(player_path) as Node2D
	queue_redraw()

func set_context(new_quest: String, new_focus_id: String, near_police: bool) -> void:
	quest_code = new_quest
	focus_id = new_focus_id
	police_near = near_police

func _map_point(world: Vector2) -> Vector2:
	var pad: Vector2 = Vector2(10.0, 24.0)
	var inner: Vector2 = size - Vector2(20.0, 34.0)
	return pad + Vector2(world.x / WORLD_SIZE.x * inner.x, world.y / WORLD_SIZE.y * inner.y)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.02, 0.03, 0.04, 0.94), true)
	draw_rect(Rect2(2.0, 2.0, size.x - 4.0, size.y - 4.0), Color(0.55, 0.52, 0.41, 0.72), false, 1.5)
	draw_string(ThemeDB.fallback_font, Vector2(11.0, 16.0), "은령마을 · OVERWORLD", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("e6dfcc"))
	draw_string(ThemeDB.fallback_font, Vector2(size.x - 25.0, 16.0), "N", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("e2bd67"))

	var map_rect: Rect2 = Rect2(8.0, 22.0, size.x - 16.0, size.y - 30.0)
	draw_rect(map_rect, Color("1b2928"), true)
	draw_line(_map_point(Vector2(0.0, 1190.0)), _map_point(Vector2(1280.0, 915.0)), Color(0.20, 0.42, 0.50, 0.92), 8.0, true)
	draw_line(_map_point(Vector2(0.0, 990.0)), _map_point(Vector2(3200.0, 930.0)), Color("8b7f69"), 9.0, true)
	draw_line(_map_point(Vector2(1750.0, 920.0)), _map_point(Vector2(2550.0, 340.0)), Color("756956"), 5.0, true)
	draw_line(_map_point(Vector2(2330.0, 930.0)), _map_point(Vector2(2990.0, 685.0)), Color("6d6255"), 5.0, true)
	draw_line(_map_point(Vector2(520.0, 980.0)), _map_point(Vector2(220.0, 680.0)), Color("7a6c59"), 4.0, true)

	# 지역명이 보여야 큰 월드의 방향성이 즉시 읽힌다.
	_draw_region_label(Vector2(1010.0, 900.0), "마을 중심")
	_draw_region_label(Vector2(2500.0, 285.0), "북쪽 숲")
	_draw_region_label(Vector2(2850.0, 760.0), "폐광 지구")
	_draw_region_label(Vector2(650.0, 1325.0), "남쪽 호수")
	_draw_region_label(Vector2(290.0, 600.0), "수호당")

	for world_pos: Vector2 in [Vector2(330.0,650.0),Vector2(710.0,855.0),Vector2(1120.0,730.0),Vector2(1480.0,790.0),Vector2(1835.0,1205.0),Vector2(2220.0,1090.0),Vector2(2860.0,640.0),Vector2(430.0,1260.0)]:
		var block_pos: Vector2 = _map_point(world_pos)
		draw_rect(Rect2(block_pos - Vector2(6.0,4.0), Vector2(12.0,8.0)), Color("6f604f"), true)

	_draw_landmark(POLICE_POS, "P", Color("93c8d3"), police_near)
	_draw_landmark(FOREST_POS, "▲", Color("85a477"), quest_code == "NIGHT_WATCH" or quest_code == "FOLLOW_MAYOR" or quest_code == "FOREST_ENTRY")
	_draw_landmark(MINE_POS, "M", Color("b59a75"), quest_code == "FOLLOW_MAYOR" or quest_code == "FOREST_ENTRY")
	_draw_landmark(SHRINE_POS, "S", Color("d7958d"), false)
	_draw_landmark(LAKE_POS, "L", Color("78a9bf"), false)
	_draw_landmark(HOME_POS, "H", Color("bd9f72"), false)

	for node: Node in get_tree().get_nodes_in_group("npc"):
		if node is Node2D:
			var npc: Node2D = node as Node2D
			var npc_id: String = str(npc.get("npc_id"))
			var col: Color = Color("e0bd69") if npc_id == focus_id else Color(0.78, 0.80, 0.72, 0.86)
			var radius: float = 3.8 if npc_id == focus_id else 2.8
			draw_circle(_map_point(npc.global_position), radius, col)

	if not is_instance_valid(player):
		return

	# current camera viewport box
	var top_left := player.global_position - VIEW_SIZE * 0.5
	var bottom_right := player.global_position + VIEW_SIZE * 0.5
	var a := _map_point(top_left)
	var b := _map_point(bottom_right)
	draw_rect(Rect2(a, b - a), Color(1.0, 1.0, 1.0, 0.0), false, 1.0)

	var pp: Vector2 = _map_point(player.global_position)
	var direction: Vector2 = Vector2.UP
	if player is CharacterBody2D:
		var body: CharacterBody2D = player as CharacterBody2D
		if body.velocity.length() > 5.0:
			direction = body.velocity.normalized()
	var right: Vector2 = direction.rotated(PI * 0.5)
	var arrow: PackedVector2Array = PackedVector2Array([
		pp + direction * 7.0,
		pp - direction * 4.5 + right * 4.2,
		pp - direction * 4.5 - right * 4.2
	])
	draw_colored_polygon(arrow, Color("fff0bb"))
	draw_polyline(PackedVector2Array([arrow[0],arrow[1],arrow[2],arrow[0]]), Color("332e26"), 1.0, true)

func _draw_landmark(world: Vector2, label: String, color: Color, active: bool) -> void:
	var p: Vector2 = _map_point(world)
	if active:
		var ring: float = 6.0 + (sin(pulse) + 1.0) * 2.0
		draw_arc(p, ring, 0.0, TAU, 20, Color(color.r, color.g, color.b, 0.34), 1.5, true)
	draw_circle(p, 4.4 if active else 3.4, color)
	draw_string(ThemeDB.fallback_font, p + Vector2(6.0,4.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.93,0.91,0.82,0.94))

func _draw_region_label(world: Vector2, label: String) -> void:
	var p: Vector2 = _map_point(world)
	var fnt: Font = ThemeDB.fallback_font
	var text_size: int = 8
	var w: float = fnt.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, text_size).x
	draw_rect(Rect2(p + Vector2(-3.0,-10.0), Vector2(w + 6.0, 12.0)), Color(0.02,0.03,0.035,0.62), true)
	draw_string(fnt, p + Vector2(0.0,-1.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1, text_size, Color(0.86,0.84,0.75,0.82))
