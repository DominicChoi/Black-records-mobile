extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var dialogue: Label = $UI/DialoguePanel/Text
@onready var dialogue_panel: Panel = $UI/DialoguePanel
@onready var quest_label: Label = $UI/TopBar/Quest
@onready var clock_label: Label = $UI/TopBar/Clock
@onready var minimap: Control = $UI/Minimap
@onready var joystick: Control = $UI/Joystick
@onready var interaction_button: Button = $UI/InteractButton
@onready var night_overlay: ColorRect = $UI/NightOverlay

var state: Node
var nearby_npc: CharacterBody2D
var autosave_accum := 0.0
var near_police := false

func _ready() -> void:
    state = preload("res://scripts/game_state.gd").new()
    add_child(state)
    joystick.changed.connect(player.set_mobile_input)
    interaction_button.pressed.connect(interact)
    var loaded := state.load_game()
    if loaded.has("player"):
        var p: Dictionary = loaded["player"]
        player.position = Vector2(float(p.get("x",520)),float(p.get("y",430)))
    dialogue_panel.visible = false
    update_ui()

func _process(delta: float) -> void:
    state.time_of_day += delta * 0.006
    if state.time_of_day >= 24.0:
        state.time_of_day -= 24.0
    autosave_accum += delta
    if autosave_accum >= 12.0:
        autosave_accum = 0.0
        state.save_game(player.position)
    update_nearby_npc()
    near_police = player.position.distance_to(Vector2(345,355)) < 72.0
    update_ui()
    minimap.queue_redraw()

func update_nearby_npc() -> void:
    nearby_npc = null
    var best := 99999.0
    for n in get_tree().get_nodes_in_group("npc"):
        var d := player.global_position.distance_to(n.global_position)
        if d < 74.0 and d < best:
            best = d
            nearby_npc = n
    interaction_button.modulate = Color.WHITE if (nearby_npc or near_police) else Color(0.55,0.55,0.55,0.7)

func interact() -> void:
    if near_police and not nearby_npc:
        state.save_game(player.position)
        get_tree().change_scene_to_file("res://scenes/police_station.tscn")
        return
    if nearby_npc:
        dialogue.text = nearby_npc.get_dialogue(state.time_of_day)
        dialogue_panel.visible = true
        if nearby_npc.npc_id == "mayor": state.flags["met_mayor"] = true
        if nearby_npc.npc_id == "reporter": state.flags["met_reporter"] = true
        if nearby_npc.npc_id == "keeper": state.flags["met_keeper"] = true
        if state.flags["met_mayor"] and state.flags["met_reporter"]:
            state.quest = "NIGHT_WATCH"
            state.flags["mayor_follow_unlocked"] = true
        state.save_game(player.position)
    else:
        dialogue.text = "조사할 대상이 없습니다. 주변의 인물이나 건물 가까이 이동해 보십시오."
        dialogue_panel.visible = true

func update_ui() -> void:
    var h := int(state.time_of_day)
    var m := int((state.time_of_day-h)*60.0)
    clock_label.text = "%02d:%02d  ·  %s" % [h,m,"안개" if state.weather=="mist" else state.weather]
    var q := {
        "ARRIVAL":"경찰지소와 마을 주민을 조사하십시오.",
        "NIGHT_WATCH":"밤이 되면 한상철의 움직임을 확인하십시오.",
        "FOLLOW_MAYOR":"한상철에게 들키지 않게 북쪽 숲까지 추적하십시오."
    }.get(state.quest,"은령마을의 기록을 조사하십시오.")
    quest_label.text = "CH.1  |  " + q
    var darkness := clamp((state.time_of_day-18.0)/5.0,0.0,0.56)
    if state.time_of_day < 5.5:
        darkness = 0.56
    night_overlay.color = Color(0.03,0.06,0.12,darkness)

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("interact"):
        interact()
