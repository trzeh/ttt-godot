extends Control

var current_color: Color = Color.BLACK
var current_width: float = 3.0

# Używamy PackedVector2Array - to specjalna, superwydajna tablica tylko dla wektorów 2D
var lines: Array[PackedVector2Array] = []
var current_line: PackedVector2Array = PackedVector2Array()

var drawing: bool = false
var last_mouse_pos: Vector2 = Vector2.ZERO

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				drawing = true
				# Zaczynamy nową ścieżkę
				current_line = PackedVector2Array()
				last_mouse_pos = get_local_mouse_position()
				current_line.append(last_mouse_pos)
			else:
				drawing = false
				# Zapisujemy ścieżkę tylko, jeśli ma więcej niż 1 punkt (żeby nie psuć draw_polyline)
				if current_line.size() > 1:
					lines.append(current_line)
				queue_redraw()
	
	elif event is InputEventMouseMotion:
		if drawing:
			var mouse_pos = get_local_mouse_position()
			var rect_size = get_rect().size
			
			# Blokujemy wychodzenie poza krawędzie płótna
			mouse_pos.x = clamp(mouse_pos.x, 0, rect_size.x)
			mouse_pos.y = clamp(mouse_pos.y, 0, rect_size.y)
			
			if mouse_pos.distance_to(last_mouse_pos) > 1.0:
				current_line.append(mouse_pos)
				last_mouse_pos = mouse_pos
				queue_redraw()

func _draw():
	# 1. Rysujemy wszystkie zapisane ścieżki
	for line in lines:
		if line.size() >= 2:
			# draw_polyline rysuje całą linię naraz, podajemy: punkty, kolor, grubość i antyaliasing (true dla gładkości)
			draw_polyline(line, current_color, current_width, true)
	
	# 2. Rysujemy ścieżkę, która jest w trakcie malowania
	if current_line.size() >= 2:
		draw_polyline(current_line, current_color, current_width, true)

# Funkcja do czyszczenia płótna (jeśli będziesz chciał dodać przycisk "Wyczyść")
func clear_canvas():
	lines.clear()
	current_line = PackedVector2Array()
	queue_redraw()
