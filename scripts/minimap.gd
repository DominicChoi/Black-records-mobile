extends Control

@export var player_path: NodePath
@onready var player: Node2D = get_node(player_path)

func _draw() -> void:
    var r := Rect2(Vector2.ZERO,size)
    draw_rect(r,Color(0.04,0.055,0.065,0.88),true)
    draw_rect(Rect2(8,8,size.x-16,size.y-16),Color("25312f"),true)
    # roads / buildings simplified
    draw_line(Vector2(12,70),Vector2(size.x-12,64),Color("756d60"),12)
    for p in [Vector2(40,38),Vector2(80,32),Vector2(120,40),Vector2(132,92)]:
        draw_rect(Rect2(p,Vector2(18,13)),Color("66594e"),true)
    draw_circle(Vector2(size.x-16,62),5,Color("526b5d"))
    var world_size := Vector2(1280,720)
    var pp := Vector2(player.global_position.x/world_size.x*size.x, player.global_position.y/world_size.y*size.y)
    draw_circle(pp,5,Color("e2d6aa"))
    draw_string(ThemeDB.fallback_font,Vector2(10,18),"은령마을",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("d9d1bd"))
