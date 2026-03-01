extends Node2D

@onready var blur_rect = %blur
@onready var title = %title
@onready var create_ctrl = %createControl
@onready var join_ctrl = %joinControl

func _start_exit_animation(actual_popup: Node):
	var tween = create_tween().set_parallel(true)
	
	tween.tween_property(actual_popup, "modulate:a", 0.0, 0.5)
	tween.tween_property(blur_rect, "modulate:a", 0.0, 1.2)
	tween.tween_property(title, "modulate:a", 0.0, 0.8)
	tween.tween_property(create_ctrl, "modulate:a", 0.0, 0.8)
	tween.tween_property(join_ctrl, "modulate:a", 0.0, 0.8)
	
	tween.chain().tween_callback(func():
		actual_popup.queue_free()
		get_tree().change_scene_to_file("res://loading.tscn")
	)
