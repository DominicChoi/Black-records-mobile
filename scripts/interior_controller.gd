extends Node

const ROOM_SCENE: PackedScene = preload("res://scenes/interior_room.tscn")
const POLICE_BG: Texture2D = preload("res://assets/backgrounds/interiors/police_station_v053.jpg")
const HALL_BG: Texture2D = preload("res://assets/backgrounds/interiors/village_hall_v053.jpg")
const INN_BG: Texture2D = preload("res://assets/backgrounds/interiors/inn_v053.jpg")

const DOORS := {
    "police": {"pos": Vector2(690, 770), "radius": 82.0, "name": "경찰지소", "bg": POLICE_BG},
    "hall": {"pos": Vector2(1160, 660), "radius": 88.0, "name": "마을회관", "bg": HALL_BG},
    "inn": {"pos": Vector2(1600, 760), "radius": 88.0, "name": "여관", "bg": INN_BG}
}

var main: Node = null
var player: CharacterBody2D = null
var room: Node2D = null
var return_position: Vector2 = Vector2.ZERO
var active_room: String = ""
var hint: Label = null
var enter_button: Button = null

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    call_deferred("_bind")

func _bind() -> void:
    var scene := get_tree().current_scene
    if scene == null or scene.name != "Main" or not scene.has_node("Player"):
        return
    main = scene
    player = scene.get_node("Player") as CharacterBody2D
    _ensure_ui()

func _process(_delta: float) -> void:
    if main == null or not is_instance_valid(main) or get_tree().current_scene != main:
        main = null
        player = null
        _remove_room()
        call_deferred("_bind")
        return
    if room != null:
        return
    var nearest := _nearest_door()
    if nearest.is_empty():
        hint.visible = false
        enter_button.visible = false
    else:
        hint.visible = true
        enter_button.visible = true
        hint.text = "%s · 내부 조사 가능" % str(DOORS[nearest]["name"])
        enter_button.text = "입장"
        active_room = nearest

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("interact"):
        if room != null:
            _exit_room()
            get_viewport().set_input_as_handled()
        elif not active_room.is_empty() and _is_near(active_room):
            _enter_room(active_room)
            get_viewport().set_input_as_handled()

func _nearest_door() -> String:
    if player == null:
        return ""
    var best := ""
    var best_d := INF
    for key: String in DOORS.keys():
        var d: float = player.global_position.distance_to(DOORS[key]["pos"])
        if d <= float(DOORS[key]["radius"]) and d < best_d:
            best = key
            best_d = d
    return best

func _is_near(key: String) -> bool:
    return player != null and player.global_position.distance_to(DOORS[key]["pos"]) <= float(DOORS[key]["radius"])

func _enter_room(key: String) -> void:
    if room != null or not DOORS.has(key):
        return
    return_position = player.global_position
    room = ROOM_SCENE.instantiate() as Node2D
    room.background = DOORS[key]["bg"]
    room.room_name = str(DOORS[key]["name"])
    room.z_index = 40
    main.add_child(room)
    player.visible = false
    player.set_physics_process(false)
    _set_world_visible(false)
    hint.text = "%s 내부 · E/조사 버튼으로 나가기" % room.room_name
    hint.visible = true
    enter_button.text = "나가기"
    enter_button.visible = true
    active_room = key
    _show_dialogue("%s 내부입니다. 기록과 주변 흔적을 살펴볼 수 있습니다." % room.room_name)

func _exit_room() -> void:
    if room == null:
        return
    room.queue_free()
    room = null
    _set_world_visible(true)
    player.global_position = return_position
    player.visible = true
    player.set_physics_process(true)
    active_room = ""
    hint.visible = false
    enter_button.visible = false

func _set_world_visible(value: bool) -> void:
    for node_name in ["World", "Mayor", "Reporter", "Keeper", "Foreground"]:
        if main.has_node(node_name):
            main.get_node(node_name).visible = value
    if main.has_node("UI/Minimap"):
        main.get_node("UI/Minimap").visible = value
    if main.has_node("UI/Joystick"):
        main.get_node("UI/Joystick").visible = value

func _ensure_ui() -> void:
    if main.has_node("UI/InteriorHint"):
        hint = main.get_node("UI/InteriorHint") as Label
        enter_button = main.get_node("UI/InteriorEnter") as Button
        if not enter_button.pressed.is_connected(_on_button_pressed):
            enter_button.pressed.connect(_on_button_pressed)
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
    enter_button.pressed.connect(_on_button_pressed)
    ui.add_child(enter_button)

func _on_button_pressed() -> void:
    if room != null:
        _exit_room()
    elif not active_room.is_empty() and _is_near(active_room):
        _enter_room(active_room)

func _show_dialogue(text: String) -> void:
    if main.has_node("UI/DialoguePanel/Text"):
        main.get_node("UI/DialoguePanel/Text").text = text
        main.get_node("UI/DialoguePanel").visible = true

func _remove_room() -> void:
    if room != null and is_instance_valid(room):
        room.queue_free()
    room = null
