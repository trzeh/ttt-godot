extends Control 

@export var popup_scene: PackedScene 

func _pressed():
	if popup_scene != null:
		var popup = popup_scene.instantiate()
		get_tree().current_scene.add_child(popup)
		
		var board = popup.get_node("background")
		
		# 1. Wymuszamy środek ciężkości (pivot) na środek deski
		board.pivot_offset = board.size / 2.0
		
		# --- NOWE: KULOODPORNE CENTROWANIE ---
		# 2. Pobieramy rozmiar całego okna gry (np. 1920x1080)
		var screen_center = get_viewport_rect().size / 2.0
		# 3. Ustawiamy pozycję deski tak, aby jej środek idealnie pokrył się ze środkiem ekranu
		board.position = screen_center - board.pivot_offset
		# -------------------------------------
		
		board.scale = Vector2.ZERO
		
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_BACK)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(board, "scale", Vector2.ONE, 0.4)
		
	else:
		print("Błąd: Nie przeciągnięto sceny popupu do Inspektora!")
