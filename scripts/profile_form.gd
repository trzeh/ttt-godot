extends Node

signal profile_ready

@onready var nick_input = %nickInput
@onready var canvas = %canvas

func _on_next_button_pressed():
	Global.player_name = nick_input.text if nick_input.text != "" else "Gracz"
	Global.player_hp = 100
	
	if canvas and "lines" in canvas:
		Global.player_avatar_data = canvas.lines.duplicate(true)
	
	profile_ready.emit()
