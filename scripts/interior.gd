extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var joystick: Control = $UI/Joystick
@onready var interact_button: Button = $UI/InteractButton
@onready var hint: Label = $UI/Hint

func _ready() -> void:
    joystick.changed.connect(player.set_mobile_input)
    interact_button.pressed.connect(try_exit)

func _process(_delta: float) -> void:
    var near_exit := player.position.distance_to(Vector2(640,650)) < 90.0
    interact_button.modulate = Color.WHITE if near_exit else Color(0.55,0.55,0.55,0.7)
    hint.text = "출입문 · 마을로 돌아가기" if near_exit else "경찰지소 · 실종 신고 기록을 조사할 수 있는 공간"

func try_exit() -> void:
    if player.position.distance_to(Vector2(640,650)) < 90.0:
        get_tree().change_scene_to_file("res://scenes/main.tscn")
