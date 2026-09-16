extends Node

const POLICE_BG: Texture2D = preload("res://assets/backgrounds/interiors/police_station_v053.jpg")
const HALL_BG: Texture2D = preload("res://assets/backgrounds/interiors/village_hall_v053.jpg")
const INN_BG: Texture2D = preload("res://assets/backgrounds/interiors/inn_v053.jpg")

# v0.5.0 대형 월드의 실제 건물 위치에 맞춘 출입 좌표.
const DOORS := {
    "police": {"pos": Vector2(710, 855), "radius": 92.0, "name": "경찰지소", "bg": POLICE_BG,
        "desc": "사건 장부와 1996년 폐광 사고 관련 기록을 확인할 수 있습니다."},
    "hall": {"pos": Vector2(1120, 730), "radius": 92.0, "name": "마을회관", "bg": HALL_BG,
        "desc": "마을 행사 기록과 주민 명부에서 비어 있는 날짜를 찾아보십시오."},
    "inn": {"pos": Vector2(1480, 790), "radius": 96.0, "name": "여관", "bg": INN_BG,
        "desc": "투숙객 명부와 야간 이동 흔적을 대조할 수 있습니다."}
}

var main: Node = null
var player: CharacterBody2D = null
var return_position: Vector2 = Vector2.ZERO
var active_room: String = ""
var hint: Label = null
var enter_button: Button = null

var overlay_layer: CanvasLayer = null
var overlay_root: Control = null
var exit_button: Button = null
var saved_visibility: Dictionary = {}
var player_physics_was_enabled: bool = true
var main_unhandled_was_enabled: bool = true

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    call_deferred("_bind")

func _bind() -> void:
    var scene := get_tree().current_scene
    if scene == null or scene.name != "Main" or not scene.has_node("Player"):
        return
    main = scene
    player = scene.get_node("Player") as CharacterBody2D
    _ensure_entry_ui()

func _process(_delta: float) -> void:
    if main == null or not is_instance_valid(main) or get_tree().current_scene != main:
        _cleanup_for_scene_change()
        call_deferred("_bind")
        return

    if overlay_layer != null:
        return

    var nearest := _nearest_door()
    active_room = nearest
    if nearest.is_empty():
        if is_instance_valid(hint):
            hint.visible = false
        if is_instance_valid(enter_button):
            enter_button.visible = false
        return

    # 경찰지소는 메인 HUD의 기존 '입장' 버튼을 재사용한다.
    # 회관/여관만 보조 입장 버튼을 표시해 UI 중복을 피한다.
    if nearest == "police":
        hint.visible = false
        enter_button.visible = false
        return

    hint.visible = true
    enter_button.visible = true
    hint.text = "%s · 내부 조사 가능" % str(DOORS[nearest]["name"])
    enter_button.text = "입장"

func _unhandled_input(event: InputEvent) -> void:
    if not event.is_action_pressed("interact"):
        return

    if overlay_layer != null:
        _exit_room()
        get_viewport().set_input_as_handled()
        return

    if not active_room.is_empty() and _is_near(active_room):
        _enter_room(active_room)
        get_viewport().set_input_as_handled()

func get_nearby_room_key() -> String:
    return _nearest_door()

func enter_from_main(key: String) -> void:
    if overlay_layer == null and DOORS.has(key) and _is_near(key):
        _enter_room(key)

func _nearest_door() -> String:
    if player == null or not is_instance_valid(player):
        return ""
    var best := ""
    var best_d: float = INF
    for key: String in DOORS.keys():
        var d: float = player.global_position.distance_to(DOORS[key]["pos"])
        if d <= float(DOORS[key]["radius"]) and d < best_d:
            best = key
            best_d = d
    return best

func _is_near(key: String) -> bool:
    if player == null or not is_instance_valid(player) or not DOORS.has(key):
        return false
    return player.global_position.distance_to(DOORS[key]["pos"]) <= float(DOORS[key]["radius"])

func _enter_room(key: String) -> void:
    if overlay_layer != null or not DOORS.has(key) or player == null:
        return

    return_position = player.global_position
    active_room = key
    _capture_and_hide_outdoor()

    overlay_layer = CanvasLayer.new()
    overlay_layer.name = "InteriorOverlayLayer"
    overlay_layer.layer = 80
    main.add_child(overlay_layer)

    overlay_root = Control.new()
    overlay_root.name = "InteriorOverlay"
    overlay_root.anchor_right = 1.0
    overlay_root.anchor_bottom = 1.0
    overlay_root.mouse_filter = Control.MOUSE_FILTER_STOP
    overlay_layer.add_child(overlay_root)

    var background := TextureRect.new()
    background.name = "Background"
    background.anchor_right = 1.0
    background.anchor_bottom = 1.0
    background.texture = DOORS[key]["bg"]
    background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
    background.mouse_filter = Control.MOUSE_FILTER_IGNORE
    overlay_root.add_child(background)

    # 실내 화면 자체의 어두운 가장자리와 상/하단 정보 영역.
    var shade := ColorRect.new()
    shade.anchor_right = 1.0
    shade.anchor_bottom = 1.0
    shade.color = Color(0.01, 0.015, 0.02, 0.10)
    shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
    overlay_root.add_child(shade)

    var top_band := ColorRect.new()
    top_band.anchor_right = 1.0
    top_band.offset_bottom = 66.0
    top_band.color = Color(0.025, 0.03, 0.035, 0.86)
    top_band.mouse_filter = Control.MOUSE_FILTER_IGNORE
    overlay_root.add_child(top_band)

    var title := Label.new()
    title.position = Vector2(30, 18)
    title.size = Vector2(760, 36)
    title.text = "은령마을  ·  %s  ·  실내 조사" % str(DOORS[key]["name"])
    title.add_theme_font_size_override("font_size", 20)
    title.add_theme_color_override("font_color", Color(0.94, 0.91, 0.82, 1.0))
    overlay_root.add_child(title)

    var bottom_band := ColorRect.new()
    bottom_band.anchor_left = 0.0
    bottom_band.anchor_top = 1.0
    bottom_band.anchor_right = 1.0
    bottom_band.anchor_bottom = 1.0
    bottom_band.offset_top = -150.0
    bottom_band.color = Color(0.025, 0.03, 0.035, 0.90)
    bottom_band.mouse_filter = Control.MOUSE_FILTER_IGNORE
    overlay_root.add_child(bottom_band)

    var room_label := Label.new()
    room_label.anchor_top = 1.0
    room_label.anchor_bottom = 1.0
    room_label.offset_left = 34.0
    room_label.offset_top = -126.0
    room_label.offset_right = 930.0
    room_label.offset_bottom = -70.0
    room_label.text = "%s 내부\n%s" % [str(DOORS[key]["name"]), str(DOORS[key]["desc"])]
    room_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    room_label.add_theme_font_size_override("font_size", 16)
    room_label.add_theme_color_override("font_color", Color(0.91, 0.90, 0.85, 0.98))
    overlay_root.add_child(room_label)

    var key_hint := Label.new()
    key_hint.anchor_left = 1.0
    key_hint.anchor_top = 1.0
    key_hint.anchor_right = 1.0
    key_hint.anchor_bottom = 1.0
    key_hint.offset_left = -330.0
    key_hint.offset_top = -125.0
    key_hint.offset_right = -32.0
    key_hint.offset_bottom = -94.0
    key_hint.text = "E / 조사 버튼으로 나가기"
    key_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    key_hint.add_theme_font_size_override("font_size", 13)
    key_hint.add_theme_color_override("font_color", Color(0.86, 0.80, 0.66, 0.96))
    overlay_root.add_child(key_hint)

    exit_button = Button.new()
    exit_button.name = "ExitButton"
    exit_button.anchor_left = 1.0
    exit_button.anchor_top = 1.0
    exit_button.anchor_right = 1.0
    exit_button.anchor_bottom = 1.0
    exit_button.offset_left = -292.0
    exit_button.offset_top = -88.0
    exit_button.offset_right = -70.0
    exit_button.offset_bottom = -28.0
    exit_button.text = "나가기"
    exit_button.add_theme_font_size_override("font_size", 19)
    exit_button.pressed.connect(_exit_room)
    overlay_root.add_child(exit_button)

func _exit_room() -> void:
    if overlay_layer == null:
        return

    overlay_layer.queue_free()
    overlay_layer = null
    overlay_root = null
    exit_button = null

    _restore_outdoor()
    if player != null and is_instance_valid(player):
        player.global_position = return_position
    active_room = ""

func _capture_and_hide_outdoor() -> void:
    saved_visibility.clear()
    var paths: Array[String] = [
        "World", "Player", "Mayor", "Reporter", "Keeper", "Foreground",
        "UI/NightOverlay", "UI/WeatherFX", "UI/TopBar", "UI/Minimap", "UI/Joystick",
        "UI/ActionHint", "UI/InteractButton", "UI/DialoguePanel", "UI/InteriorHint", "UI/InteriorEnter"
    ]
    for path: String in paths:
        if main.has_node(path):
            var node := main.get_node(path)
            if node is CanvasItem:
                var canvas_item := node as CanvasItem
                saved_visibility[path] = canvas_item.visible
                canvas_item.visible = false

    player_physics_was_enabled = player.is_physics_processing()
    player.set_physics_process(false)
    main_unhandled_was_enabled = main.is_processing_unhandled_input()
    main.set_process_unhandled_input(false)

func _restore_outdoor() -> void:
    if main == null or not is_instance_valid(main):
        return
    for path: String in saved_visibility.keys():
        if main.has_node(path):
            var node := main.get_node(path)
            if node is CanvasItem:
                (node as CanvasItem).visible = bool(saved_visibility[path])
    saved_visibility.clear()

    if player != null and is_instance_valid(player):
        player.set_physics_process(player_physics_was_enabled)
    main.set_process_unhandled_input(main_unhandled_was_enabled)

    if is_instance_valid(hint):
        hint.visible = false
    if is_instance_valid(enter_button):
        enter_button.visible = false

func _ensure_entry_ui() -> void:
    if main.has_node("UI/InteriorHint"):
        hint = main.get_node("UI/InteriorHint") as Label
        enter_button = main.get_node("UI/InteriorEnter") as Button
        if not enter_button.pressed.is_connected(_on_entry_button_pressed):
            enter_button.pressed.connect(_on_entry_button_pressed)
        return

    var ui := main.get_node("UI") as CanvasLayer
    hint = Label.new()
    hint.name = "InteriorHint"
    hint.position = Vector2(430, 500)
    hint.size = Vector2(420, 32)
    hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    hint.add_theme_font_size_override("font_size", 15)
    hint.add_theme_color_override("font_color", Color(0.95, 0.88, 0.70, 0.96))
    hint.visible = false
    ui.add_child(hint)

    enter_button = Button.new()
    enter_button.name = "InteriorEnter"
    enter_button.position = Vector2(555, 526)
    enter_button.size = Vector2(170, 52)
    enter_button.text = "입장"
    enter_button.add_theme_font_size_override("font_size", 18)
    enter_button.visible = false
    enter_button.pressed.connect(_on_entry_button_pressed)
    ui.add_child(enter_button)

func _on_entry_button_pressed() -> void:
    if overlay_layer != null:
        _exit_room()
    elif not active_room.is_empty() and _is_near(active_room):
        _enter_room(active_room)

func _cleanup_for_scene_change() -> void:
    if overlay_layer != null and is_instance_valid(overlay_layer):
        overlay_layer.queue_free()
    overlay_layer = null
    overlay_root = null
    exit_button = null
    main = null
    player = null
    hint = null
    enter_button = null
    active_room = ""
    saved_visibility.clear()
