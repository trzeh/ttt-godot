extends Control

# Opcjonalnie: nadpisz by zmienić kolor/grubość linii wyświetlanego awatara
@export var line_color: Color = Color.BLACK
@export var line_width: float = 3.0

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	var avatar_lines: Array = Global.player_avatar_data
	for line in avatar_lines:
		if line is PackedVector2Array and line.size() >= 2:
			# Skalujemy punkty do rozmiaru tego węzła
			var src_size := Vector2(915.0, 732.0) # rozmiar oryginalnego canvas
			var dst_size := get_rect().size
			var scale_factor := dst_size / src_size

			var scaled_line := PackedVector2Array()
			for point in line:
				scaled_line.append(point * scale_factor)

			draw_polyline(scaled_line, line_color, line_width, true)
