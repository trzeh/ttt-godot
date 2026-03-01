extends CanvasLayer

const BUNGEE = preload("res://assets/global/Bungee-Regular.ttf")

var _overlay: ColorRect = null


func _ready() -> void:
	layer = 110
	_build_ui()


func _build_ui() -> void:
	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 0.85)
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_overlay)
	
	var title = Label.new()
	title.text = "GAME OVER"
	title.add_theme_font_override("font", BUNGEE)
	title.add_theme_font_size_override("font_size", 120)
	title.add_theme_color_override("font_color", Color(0.9, 0.15, 0.1))
	title.add_theme_color_override("font_outline_color", Color.BLACK)
	title.add_theme_constant_override("outline_size", 10)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	title.offset_top = -120
	_overlay.add_child(title)
	
	var subtitle = Label.new()
	subtitle.text = "Twój turysta nie przetrwał podróży..."
	subtitle.add_theme_font_override("font", BUNGEE)
	subtitle.add_theme_font_size_override("font_size", 36)
	subtitle.add_theme_color_override("font_outline_color", Color.BLACK)
	subtitle.add_theme_constant_override("outline_size", 4)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	subtitle.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	subtitle.offset_top = 40
	_overlay.add_child(subtitle)
	
	# Animate in
	_overlay.modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(_overlay, "modulate:a", 1.0, 0.8)
	tween.tween_interval(2.5)
	tween.tween_callback(_go_to_lobby)


func _go_to_lobby() -> void:
	Global.player_hp = Global.max_hp
	LevelManager.current_level = 1
	PlayerBanner.hide_banner()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
	queue_free()
