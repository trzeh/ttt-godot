extends Control

@onready var nick_input = $demo/background/nickInput
@onready var canvas = $demo/background/avatarArea/canvas
@onready var demo_popup = $demo
@onready var blur_rect = $mainmenu/blur
@onready var main_ui_elements = [$mainmenu/title, $mainmenu/Control, $mainmenu/Control2]

func _on_next_button_pressed():
	# 1. TWORZENIE PROFILU
	save_player_profile()
	
	# 2. ANIMACJE ZNIKANIA (TWEEN)
	var tween = create_tween().set_parallel(true)
	
	# Zniknięcie popupu demo
	tween.tween_property(demo_popup, "modulate:a", 0.0, 0.5)
	
	# Stopniowe zniknięcie blura
	tween.tween_property(blur_rect, "modulate:a", 0.0, 1.0)
	
	# Zniknięcie przycisków i tytułu
	for element in main_ui_elements:
		tween.tween_property(element, "modulate:a", 0.0, 0.8)
	
	# Po zakończeniu animacji usuwamy popup
	tween.chain().tween_callback(demo_popup.queue_free)
	print("Profil zapisany: ", Global.player_name, " HP: ", Global.player_hp)

func save_player_profile():
	# Zapisanie imienia
	Global.player_name = nick_input.text if nick_input.text != "" else "Nieznajomy"
	Global.player_hp = 100
	
	# PRZECHWYCENIE RYSUNKU (Avatar)
	# Metoda: Renderowanie zawartości canvasa do obrazka
	var img = get_viewport().get_texture().get_image()
	# Wycinamy fragment tam gdzie jest canvas (uproszczone)
	var canvas_rect = canvas.get_global_rect()
	Global.player_avatar = img.get_region(canvas_rect)
