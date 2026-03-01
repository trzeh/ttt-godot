extends Node2D

# Upewnij się, że te nazwy są identyczne jak w Twoim drzewie (obrazek 1)
@onready var blur_rect = %blur
@onready var title = %title
@onready var create_ctrl = %createControl
@onready var join_ctrl = %joinControl
@onready var demo_popup = %demoControl 

func _ready():
	# SZUKAMY SYGNAŁU: Sprawdzamy czy sygnał jest na demoControl 
	# lub na jego dziecku o nazwie 'script'
	var signal_node = demo_popup
	if demo_popup.has_node("script"):
		signal_node = demo_popup.get_node("script")
	
	if signal_node.has_signal("profile_ready"):
		signal_node.profile_ready.connect(_start_exit_animation)
		print("POŁĄCZONO: MainMenu słucha teraz węzła: ", signal_node.name)
	else:
		print("BŁĄD: Nie znaleziono sygnału profile_ready na żadnym węźle!")

func _start_exit_animation():
	print("ANIMACJA: Startuję znikanie menu...")
	var tween = create_tween().set_parallel(true)
	
	# Wszystkie elementy znikają jednocześnie
	tween.tween_property(demo_popup, "modulate:a", 0.0, 0.5)
	tween.tween_property(blur_rect, "modulate:a", 0.0, 1.2)
	tween.tween_property(title, "modulate:a", 0.0, 0.8)
	tween.tween_property(create_ctrl, "modulate:a", 0.0, 0.8)
	tween.tween_property(join_ctrl, "modulate:a", 0.0, 0.8)
	
	tween.chain().tween_callback(func():
		demo_popup.queue_free()
		print("GOTOWE: Popup usunięty.")
	)
