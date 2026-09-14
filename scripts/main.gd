extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var dialogue: Label = $UI/DialoguePanel/Text
@onready var dialogue_panel: Panel = $UI/DialoguePanel
@onready var quest_label: Label = $UI/TopBar/Quest
@onready var clock_label: Label = $UI/TopBar/Clock
@onready var area_label: Label = $UI/TopBar/Area
@onready var action_hint: Label = $UI/ActionHint
@onready var minimap: Control = $UI/Minimap
@onready var joystick: Control = $UI/Joystick
@onready var interaction_button: Button = $UI/InteractButton
@onready var night_overlay: ColorRect = $UI/NightOverlay
@onready var world: Node2D = $World
@onready var weather_fx: Control = $UI/WeatherFX

var state: Node
var nearby_npc: CharacterBody2D
var autosave_accum: float = 0.0
var near_police: bool = false

func _ready() -> void:
    state = preload("res://scripts/game_state.gd").new()
    add_child(state)
    joystick.changed.connect(player.set_mobile_input)
    interaction_button.pressed.connect(interact)
    var loaded: Dictionary = state.load_game()
    if loaded.has("player"):
        var p: Dictionary = loaded["player"] as Dictionary
        player.position = Vector2(float(p.get("x", 520.0)), float(p.get("y", 430.0)))
    dialogue_panel.visible = false
    update_environment(true)
    update_ui()

func _process(delta: float) -> void:
    state.time_of_day += delta * 0.006
    if state.time_of_day >= 24.0:
        state.time_of_day -= 24.0
    autosave_accum += delta
    if autosave_accum >= 12.0:
        autosave_accum = 0.0
        state.save_game(player.position)
    update_environment(false)
    update_npc_story_context()
    update_nearby_npc()
    near_police = player.position.distance_to(Vector2(345.0, 355.0)) < 72.0
    update_ui()

func update_environment(force_refresh: bool = false) -> void:
    var next_weather: String = _weather_for_hour(float(state.time_of_day))
    if force_refresh or next_weather != str(state.weather):
        state.weather = next_weather
    if world.has_method("set_environment"):
        world.call("set_environment", float(state.time_of_day), str(state.weather))
    if weather_fx.has_method("set_environment"):
        weather_fx.call("set_environment", float(state.time_of_day), str(state.weather))

func _weather_for_hour(hour: float) -> String:
    if hour < 5.5:
        return "mist"
    if hour < 8.0:
        return "mist"
    if hour < 15.5:
        return "clear"
    if hour < 19.2:
        return "overcast"
    if hour < 22.8:
        return "drizzle"
    return "mist"

func _weather_label(code: String) -> String:
    var labels: Dictionary = {
        "clear": "맑음",
        "mist": "안개",
        "overcast": "흐림",
        "drizzle": "이슬비"
    }
    return str(labels.get(code, code))

func update_npc_story_context() -> void:
    for n: Node in get_tree().get_nodes_in_group("npc"):
        if n.has_method("set_story_context"):
            n.call("set_story_context", str(state.quest), state.flags, float(state.time_of_day))

func update_nearby_npc() -> void:
    nearby_npc = null
    var best: float = 99999.0
    for n: Node in get_tree().get_nodes_in_group("npc"):
        if not n is CharacterBody2D:
            continue
        var npc := n as CharacterBody2D
        var d: float = player.global_position.distance_to(npc.global_position)
        if d < 74.0 and d < best:
            best = d
            nearby_npc = npc

func interact() -> void:
    if near_police and nearby_npc == null:
        state.save_game(player.position)
        get_tree().change_scene_to_file("res://scenes/police_station.tscn")
        return
    if nearby_npc != null:
        dialogue.text = nearby_npc.get_dialogue(float(state.time_of_day), str(state.quest), state.flags)
        dialogue_panel.visible = true
        if nearby_npc.npc_id == "mayor":
            state.flags["met_mayor"] = true
        if nearby_npc.npc_id == "reporter":
            state.flags["met_reporter"] = true
        if nearby_npc.npc_id == "keeper":
            state.flags["met_keeper"] = true
        if bool(state.flags["met_mayor"]) and bool(state.flags["met_reporter"]):
            state.quest = "NIGHT_WATCH"
            state.flags["mayor_follow_unlocked"] = true
        state.save_game(player.position)
    else:
        dialogue.text = "조사할 대상이 없습니다. 미니맵의 표시와 주변 인물 표식을 확인해 보십시오."
        dialogue_panel.visible = true

func update_ui() -> void:
    var h: int = int(state.time_of_day)
    var m: int = int((state.time_of_day - float(h)) * 60.0)
    var weather_text: String = _weather_label(str(state.weather))
    clock_label.text = "%02d:%02d  ·  %s" % [h, m, weather_text]
    area_label.text = "은령마을"

    var quest_texts: Dictionary = {
        "ARRIVAL": "경찰지소와 마을 주민을 조사하십시오.",
        "NIGHT_WATCH": "밤이 되면 한상철의 움직임을 확인하십시오.",
        "FOLLOW_MAYOR": "한상철에게 들키지 않게 북쪽 숲까지 추적하십시오."
    }
    var q: String = str(quest_texts.get(state.quest, "은령마을의 기록을 조사하십시오."))
    quest_label.text = "CH.1  ◆  " + q

    var focus_id: String = ""
    if nearby_npc != null:
        focus_id = str(nearby_npc.npc_id)
        interaction_button.text = "대화"
        var schedule_text: String = ""
        if nearby_npc.has_method("get_schedule_label"):
            schedule_text = str(nearby_npc.call("get_schedule_label"))
        action_hint.text = "%s · %s" % [str(nearby_npc.display_name), schedule_text if not schedule_text.is_empty() else str(nearby_npc.role)]
        interaction_button.disabled = false
    elif near_police:
        interaction_button.text = "입장"
        action_hint.text = "경찰지소"
        interaction_button.disabled = false
    else:
        interaction_button.text = "조사"
        action_hint.text = "대상 가까이 이동"
        interaction_button.disabled = true

    interaction_button.modulate = Color.WHITE if not interaction_button.disabled else Color(0.60, 0.62, 0.64, 0.70)
    minimap.set_context(str(state.quest), focus_id, near_police)

    var hour: float = float(state.time_of_day)
    var darkness: float = 0.0
    if hour >= 18.0:
        darkness = clampf((hour - 18.0) / 4.2, 0.0, 0.58)
    elif hour < 6.5:
        darkness = 0.58 * (1.0 - clampf((hour - 5.0) / 1.5, 0.0, 1.0))

    var weather_bonus: float = 0.0
    if str(state.weather) == "overcast":
        weather_bonus = 0.05
    elif str(state.weather) == "drizzle":
        weather_bonus = 0.08
    elif str(state.weather) == "mist":
        weather_bonus = 0.025

    var dusk_warmth: float = 0.0
    if hour >= 17.0 and hour <= 19.4:
        dusk_warmth = sin(clampf((hour - 17.0) / 2.4, 0.0, 1.0) * PI)
    var overlay_color := Color(0.035 + 0.08 * dusk_warmth, 0.055, 0.11 - 0.025 * dusk_warmth, clampf(darkness + weather_bonus, 0.0, 0.64))
    night_overlay.color = overlay_color

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("interact"):
        interact()
