extends Node2D

const BUNGEE = preload("res://assets/global/Bungee-Regular.ttf")

@onready var blur_rect = %blur
@onready var title = %title
@onready var create_ctrl = %createControl
@onready var join_ctrl = %joinControl

var _demo_label: Label = null

func _ready():
	PlayerBanner.hide_banner()
	
	var create_btn = create_ctrl.get_node("createButton")
	if create_btn:
		create_btn.popup_scene = null
		for conn in create_btn.get_signal_connection_list("pressed"):
			create_btn.disconnect("pressed", conn["callable"])
		create_btn.pressed.connect(_show_demo_unavailable)
	
	var join_btn = join_ctrl.get_node("secondaryButton")
	if join_btn:
		join_btn.popup_scene = null
		for conn in join_btn.get_signal_connection_list("pressed"):
			join_btn.disconnect("pressed", conn["callable"])
		join_btn.pressed.connect(_show_demo_unavailable)

func _show_demo_unavailable():
	if _demo_label and is_instance_valid(_demo_label):
		_demo_label.queue_free()
	
	_demo_label = Label.new()
	_demo_label.text = "NIEDOSTĘPNE W DEMO"
	_demo_label.add_theme_font_override("font", BUNGEE)
	_demo_label.add_theme_font_size_override("font_size", 48)
	_demo_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.2))
	_demo_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_demo_label.add_theme_constant_override("outline_size", 6)
	_demo_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_demo_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_demo_label.position = Vector2(960 - 350, 480)
	_demo_label.size = Vector2(700, 80)
	add_child(_demo_label)
	
	var tween = create_tween()
	_demo_label.modulate = Color(1, 1, 1, 0)
	tween.tween_property(_demo_label, "modulate:a", 1.0, 0.3)
	tween.tween_interval(1.5)
	tween.tween_property(_demo_label, "modulate:a", 0.0, 0.5)
	tween.tween_callback(_demo_label.queue_free)

func _start_exit_animation(actual_popup: Node):
	var tween = create_tween().set_parallel(true)
	
	tween.tween_property(actual_popup, "modulate:a", 0.0, 0.5)
	tween.tween_property(blur_rect, "modulate:a", 0.0, 1.2)
	tween.tween_property(title, "modulate:a", 0.0, 0.8)
	tween.tween_property(create_ctrl, "modulate:a", 0.0, 0.8)
	tween.tween_property(join_ctrl, "modulate:a", 0.0, 0.8)
	
	tween.chain().tween_callback(func():
		actual_popup.queue_free()
		get_tree().change_scene_to_file("res://scenes/Loading.tscn")
	)
