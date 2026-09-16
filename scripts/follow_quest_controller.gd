extends Node

var main: Node = null
var player: CharacterBody2D = null
var mayor: CharacterBody2D = null
var state: Node = null
var hud_layer: CanvasLayer = null
var status_panel: Panel = null
var status_label: Label = null
var meter: ProgressBar = null
var active: bool = false
var lost_time: float = 0.0
var danger_time: float = 0.0
var safe_follow_time: float = 0.0
var last_checkpoint: Vector2 = Vector2.ZERO

const START_HOUR: float = 21.65
const IDEAL_MIN: float = 120.0
const IDEAL_MAX: float = 260.0
const DANGER_DISTANCE: float = 92.0
const LOST_DISTANCE: float = 420.0
const COMPLETE_POS: Vector2 = Vector2(2540.0, 352.0)

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    call_deferred("_bind_scene")

func _bind_scene() -> void:
    var scene: Node = get_tree().current_scene
    if scene == null or scene.name != "Main":
        return
    if not scene.has_node("Player") or not scene.has_node("Mayor"):
        return
    main = scene
    player = scene.get_node("Player") as CharacterBody2D
    mayor = scene.get_node("Mayor") as CharacterBody2D
    state = scene.get("state") as Node
    _ensure_hud()

func _process(delta: float) -> void:
    if main == null or not is_instance_valid(main) or get_tree().current_scene != main:
        main = null
        player = null
        mayor = null
        state = null
        active = false
        _remove_hud()
        call_deferred("_bind_scene")
        return
    if state == null:
        state = main.get("state") as Node
        if state == null:
            return
    _update_activation()
    if active:
        _update_pursuit(delta)
    elif status_panel != null:
        status_panel.visible = false

func _update_activation() -> void:
    var quest: String = str(state.get("quest"))
    var hour: float = float(state.get("time_of_day"))
    var flags: Dictionary = state.get("flags") as Dictionary
    if quest == "NIGHT_WATCH" and hour >= START_HOUR and bool(flags.get("mayor_follow_unlocked", false)):
        state.set("quest", "FOLLOW_MAYOR")
        active = true
        last_checkpoint = player.global_position
        _show_message("미행 시작 · 북쪽 숲 입구까지 한상철을 추적하십시오.")
        if state.has_method("save_game"):
            state.call("save_game", player.position)
    elif quest == "FOLLOW_MAYOR":
        active = true
    else:
        active = false

func _update_pursuit(delta: float) -> void:
    if not is_instance_valid(player) or not is_instance_valid(mayor):
        return
    var distance: float = player.global_position.distance_to(mayor.global_position)
    var flags: Dictionary = state.get("flags") as Dictionary

    if distance < DANGER_DISTANCE:
        danger_time += delta
        lost_time = 0.0
        safe_follow_time = maxf(0.0, safe_follow_time - delta * 0.7)
        _set_status("너무 가깝습니다 · 들킬 위험", 100.0, true)
        if danger_time >= 2.6:
            danger_time = 0.0
            player.global_position = last_checkpoint
            _show_message("한상철이 인기척을 느꼈습니다. 마지막 안전 지점으로 후퇴합니다.")
    elif distance > LOST_DISTANCE:
        lost_time += delta
        danger_time = 0.0
        safe_follow_time = maxf(0.0, safe_follow_time - delta)
        _set_status("거리가 너무 멉니다 · 시야 확보", clampf((distance - LOST_DISTANCE) / 2.0, 0.0, 100.0), true)
        if lost_time >= 4.5:
            lost_time = 0.0
            player.global_position = last_checkpoint
            _show_message("한상철을 놓쳤습니다. 마지막 확인 지점으로 돌아갑니다.")
    else:
        lost_time = 0.0
        danger_time = 0.0
        if distance >= IDEAL_MIN and distance <= IDEAL_MAX:
            safe_follow_time += delta
            if safe_follow_time >= 1.2:
                last_checkpoint = player.global_position
                safe_follow_time = 0.0
            _set_status("적정 거리 · 발소리를 죽이고 추적", 35.0, false)
        else:
            _set_status("거리 조정 중", 58.0, false)

    if mayor.global_position.distance_to(COMPLETE_POS) < 58.0 and player.global_position.distance_to(mayor.global_position) < LOST_DISTANCE:
        flags["night_follow_complete"] = true
        flags["north_forest_unlocked"] = true
        flags["mine_road_hint"] = true
        state.set("flags", flags)
        state.set("quest", "FOREST_ENTRY")
        active = false
        _show_message("추적 성공 · 한상철이 북쪽 숲 초입으로 사라졌습니다. 숲 입구와 동쪽 폐광 진입로를 조사하십시오.")
        if state.has_method("save_game"):
            state.call("save_game", player.position)

func _ensure_hud() -> void:
    if hud_layer != null:
        return
    hud_layer = CanvasLayer.new()
    hud_layer.layer = 30
    hud_layer.name = "NightPursuitHUD"
    main.add_child(hud_layer)

    status_panel = Panel.new()
    status_panel.position = Vector2(420.0, 82.0)
    status_panel.size = Vector2(440.0, 58.0)
    status_panel.visible = false
    hud_layer.add_child(status_panel)

    status_label = Label.new()
    status_label.position = Vector2(16.0, 7.0)
    status_label.size = Vector2(408.0, 22.0)
    status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    status_label.add_theme_font_size_override("font_size", 14)
    status_panel.add_child(status_label)

    meter = ProgressBar.new()
    meter.position = Vector2(18.0, 34.0)
    meter.size = Vector2(404.0, 10.0)
    meter.show_percentage = false
    meter.min_value = 0.0
    meter.max_value = 100.0
    status_panel.add_child(meter)

func _set_status(text: String, value: float, danger: bool) -> void:
    if status_panel == null:
        return
    status_panel.visible = true
    status_label.text = text
    status_label.modulate = Color(1.0, 0.62, 0.52, 1.0) if danger else Color(0.92, 0.88, 0.72, 1.0)
    meter.value = value

func _show_message(text: String) -> void:
    if main != null and main.has_node("UI/DialoguePanel/Text"):
        var label: Label = main.get_node("UI/DialoguePanel/Text") as Label
        var panel: Panel = main.get_node("UI/DialoguePanel") as Panel
        label.text = text
        panel.visible = true

func _remove_hud() -> void:
    if hud_layer != null and is_instance_valid(hud_layer):
        hud_layer.queue_free()
    hud_layer = null
    status_panel = null
    status_label = null
    meter = null
