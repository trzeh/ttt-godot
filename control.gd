extends Node2D

@onready var blur_rect = %blur
@onready var title = %title
@onready var create_ctrl = %createControl
@onready var join_ctrl = %joinControl

# _start_exit_animation teraz przyjmuje faktyczny popup jako parametr
# (przekazywany przez .bind() z secondary_button.gd)
func _start_exit_animation(actual_popup: Node):
	print("ANIMACJA: Startuję znikanie menu...")
	var tween = create_tween().set_parallel(true)
	
	# Animujemy właściwy popup + elementy menu
	tween.tween_property(actual_popup, "modulate:a", 0.0, 0.5)
	tween.tween_property(blur_rect, "modulate:a", 0.0, 1.2)
	tween.tween_property(title, "modulate:a", 0.0, 0.8)
	tween.tween_property(create_ctrl, "modulate:a", 0.0, 0.8)
	tween.tween_property(join_ctrl, "modulate:a", 0.0, 0.8)
	
	tween.chain().tween_callback(func():
		actual_popup.queue_free()
		print("GOTOWE: Popup usunięty, gracz: ", Global.player_name)
		get_tree().change_scene_to_file("res://loading.tscn")
	)
