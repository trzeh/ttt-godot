extends TextureButton # zależnie od tego czego używasz

func _pressed():
	# 1. Szukamy głównego węzła naszej sceny (tego, który ma pivot na środku)
	# 'owner' to zazwyczaj główny węzeł sceny, w której znajduje się przycisk
	var popup = owner 
	
	if popup:
		var tween = create_tween()
		
		# Używamy TRANS_BACK i EASE_IN, aby uzyskać efekt "zasysania"
		# Obiekt najpierw lekko drgnie, a potem szybko zniknie
		tween.set_trans(Tween.TRANS_BACK)
		tween.set_ease(Tween.EASE_IN)
		
		# 2. Animujemy skalę do zera
		tween.tween_property(popup, "scale", Vector2.ZERO, 0.3)
		
		# 3. KLUCZOWY MOMENT: Czekamy, aż animacja się skończy i usuwamy popup
		# Funkcja 'finished' Tweena wywoła 'queue_free', gdy skala osiągnie 0
		tween.finished.connect(popup.queue_free)

func _on_pressed() -> void:
	pass # Replace with function body.
