extends Node

const SAVE_PATH := "user://black_records_v02.save"

var chapter := 1
var quest := "ARRIVAL"
var time_of_day := 17.5
var weather := "mist"
var flags := {
    "met_mayor": false,
    "met_reporter": false,
    "met_keeper": false,
    "mayor_follow_unlocked": false
}

func save_game(player_pos: Vector2) -> void:
    var data := {
        "version": "0.2.7",
        "chapter": chapter,
        "quest": quest,
        "time_of_day": time_of_day,
        "weather": weather,
        "flags": flags,
        "player": {"x": player_pos.x, "y": player_pos.y}
    }
    var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if f:
        f.store_string(JSON.stringify(data))

func load_game() -> Dictionary:
    if not FileAccess.file_exists(SAVE_PATH):
        return {}
    var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if not f:
        return {}
    var parsed = JSON.parse_string(f.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY:
        return {}
    chapter = int(parsed.get("chapter", 1))
    quest = str(parsed.get("quest", "ARRIVAL"))
    time_of_day = float(parsed.get("time_of_day", 17.5))
    weather = str(parsed.get("weather", "mist"))
    flags.merge(parsed.get("flags", {}), true)
    return parsed
