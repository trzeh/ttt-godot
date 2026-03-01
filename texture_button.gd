extends Node

# Definiujemy sygnał, którego szuka control.gd
signal profile_ready 

# Węzły wewnątrz sceny demo
@onready var nick_input = %nickInput
@onready var canvas = %canvas

# Ta funkcja musi być podpięta pod sygnał 'pressed' przycisku nextButton
func _on_next_button_pressed():
	# 0. TWORZENIE PROFILU W GLOBALU
	Global.player_name = nick_input.text if nick_input.text != "" else "Gracz"
	Global.player_hp = 100
	
	# Zapisujemy rysunek (poprawiono błąd 'canvas.line' na 'canvas.lines')
	if canvas and "lines" in canvas:
		Global.player_avatar_data = canvas.lines.duplicate(true)
		print("Dane rysunku przekazane do Globala")
	
	# 1. Wysyłamy sygnał, który odpali animację w mainmenu
	profile_ready.emit()
	print("Wysłano sygnał profile_ready")
