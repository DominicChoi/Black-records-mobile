extends Node2D

func _draw() -> void:
    draw_rect(Rect2(0,0,1280,720),Color("191c1d"),true)
    draw_rect(Rect2(110,80,1060,560),Color("454039"),true)
    draw_rect(Rect2(135,105,1010,510),Color("6a6257"),true)
    # wood floor
    for y in range(130,600,38):
        draw_line(Vector2(145,y),Vector2(1135,y),Color("5a5249"),2)
    # service desk
    draw_rect(Rect2(315,245,650,92),Color("3e342c"),true)
    draw_rect(Rect2(335,225,610,28),Color("78654f"),true)
    draw_string(ThemeDB.fallback_font,Vector2(530,210),"은령 경찰지소",HORIZONTAL_ALIGNMENT_LEFT,-1,25,Color("ddd5c2"))
    # archive shelves
    for x in [170,1010]:
        draw_rect(Rect2(x,165,95,300),Color("332d28"),true)
        for y in range(185,445,45):
            draw_line(Vector2(x+8,y),Vector2(x+87,y),Color("8c7656"),5)
    # evidence board
    draw_rect(Rect2(420,405,440,135),Color("2b3935"),true)
    draw_string(ThemeDB.fallback_font,Vector2(445,438),"1996년 폐광 사고 기록",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("d7d1c4"))
    draw_line(Vector2(465,470),Vector2(650,500),Color("9d5f55"),2)
    draw_line(Vector2(780,460),Vector2(650,500),Color("9d5f55"),2)
    # exit
    draw_rect(Rect2(595,590,90,50),Color("232a2b"),true)
    draw_string(ThemeDB.fallback_font,Vector2(608,622),"출구",HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("d5ccb6"))
