extends Control 

@export var popup_scene: PackedScene 

func _pressed():
	if popup_scene != null:
		var popup = popup_scene.instantiate()
		get_tree().current_scene.add_child(popup)
		
		# 1. Pobieramy rozmiar całego okna gry (np. 1920x1080)
		var screen_size = get_viewport_rect().size
		
		# 2. Ustawiamy środek ciężkości (pivot) CAŁEJ SCENY na idealny środek ekranu
		popup.pivot_offset = screen_size / 2.0
		
		# 3. Zmniejszamy CAŁĄ SCENĘ (wraz ze wszystkim co w niej jest) do zera
		popup.scale = Vector2.ZERO
		
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_BACK)
		tween.set_ease(Tween.EASE_OUT)
		
		# 4. Animujemy powiększenie CAŁEJ SCENY do normalnego rozmiaru
		tween.tween_property(popup, "scale", Vector2.ONE, 0.4)
		
	else:
		print("Błąd: Nie przeciągnięto sceny popupu do Inspektora!")
