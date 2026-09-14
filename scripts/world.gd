extends Node2D

var lanterns := [Vector2(330,260),Vector2(760,250),Vector2(1040,430),Vector2(510,520)]
var trees := [Vector2(90,120),Vector2(170,155),Vector2(1160,110),Vector2(1110,180),Vector2(1150,590),Vector2(80,600)]
var t := 0.0

func _process(delta: float) -> void:
    t += delta
    queue_redraw()

func _draw() -> void:
    # ground and mountain edge
    draw_rect(Rect2(0,0,1280,720),Color("26332f"),true)
    draw_polygon(PackedVector2Array([Vector2(0,0),Vector2(1280,0),Vector2(1280,125),Vector2(940,80),Vector2(610,118),Vector2(300,70),Vector2(0,130)]),PackedColorArray([Color("17231f")]))
    # main road
    var road := PackedVector2Array([Vector2(0,400),Vector2(280,365),Vector2(610,390),Vector2(970,350),Vector2(1280,380),Vector2(1280,500),Vector2(960,470),Vector2(620,500),Vector2(300,460),Vector2(0,510)])
    draw_colored_polygon(road,Color("6d6558"))
    draw_polyline(PackedVector2Array([Vector2(0,442),Vector2(300,410),Vector2(620,445),Vector2(970,410),Vector2(1280,440)]),Color("898071"),3)
    # village houses
    draw_house(Vector2(250,250),Vector2(190,115),"경찰지소",Color("46545a"))
    draw_house(Vector2(555,205),Vector2(210,135),"마을회관",Color("5d4f46"))
    draw_house(Vector2(900,235),Vector2(170,105),"여관",Color("544c40"))
    draw_house(Vector2(910,505),Vector2(210,105),"한상철 자택",Color("443f3a"))
    # north forest gate
    draw_rect(Rect2(1190,280,90,170),Color("192421"),true)
    draw_string(ThemeDB.fallback_font,Vector2(1185,270),"북쪽 숲",HORIZONTAL_ALIGNMENT_LEFT,100,18,Color("d7cfb5"))
    for p in trees:
        draw_tree(p)
    for p in lanterns:
        var glow := 19.0 + sin(t*2.0+p.x)*2.0
        draw_circle(p,glow,Color(1.0,0.68,0.34,0.07))
        draw_line(p+Vector2(0,-2),p+Vector2(0,35),Color("2c2925"),4)
        draw_circle(p,5,Color("e8ad63"))
    # stream + bridge
    draw_rect(Rect2(30,530,410,42),Color("28434a"),true)
    for x in range(45,430,34):
        draw_line(Vector2(x,542+sin(x*0.05+t)*3),Vector2(x+22,542+sin(x*0.05+t)*3),Color("5d7b7e"),2)
    draw_rect(Rect2(360,515,75,70),Color("6b5840"),true)

func draw_house(pos: Vector2, size: Vector2, label: String, wall: Color) -> void:
    draw_rect(Rect2(pos,size),wall,true)
    var roof := PackedVector2Array([pos+Vector2(-12,5),pos+Vector2(size.x/2,-38),pos+Vector2(size.x+12,5)])
    draw_colored_polygon(roof,Color("2a2928"))
    draw_rect(Rect2(pos+Vector2(size.x*0.42,size.y*0.48),Vector2(34,size.y*0.52)),Color("292725"),true)
    draw_rect(Rect2(pos+Vector2(22,35),Vector2(36,28)),Color("b58f59"),true)
    draw_string(ThemeDB.fallback_font,pos+Vector2(12,-9),label,HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("ddd6c4"))

func draw_tree(p: Vector2) -> void:
    draw_line(p,p+Vector2(0,55),Color("514132"),7)
    draw_circle(p+Vector2(0,-10),25,Color("1b3027"))
    draw_circle(p+Vector2(-15,4),18,Color("20382d"))
    draw_circle(p+Vector2(16,6),19,Color("1c3329"))
