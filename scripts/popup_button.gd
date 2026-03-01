extends Control

@export var popup_scene: PackedScene

func _pressed():
	if popup_scene == null:
		return
	
	var popup = popup_scene.instantiate()
	get_tree().current_scene.add_child(popup)
	
	var screen_size = get_viewport_rect().size
	popup.pivot_offset = screen_size / 2.0
	popup.scale = Vector2.ZERO
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(popup, "scale", Vector2.ONE, 0.4)
	
	if popup.has_signal("profile_ready"):
		var main_node = get_tree().current_scene
		if main_node.has_method("_start_exit_animation"):
			popup.profile_ready.connect(main_node._start_exit_animation.bind(popup))
