extends Control

signal event_completed(result: Dictionary)

@export var time_limit: float = 10.0
@export var hp_penalty: int = 25

const BUNGEE = preload("res://assets/global/Bungee-Regular.ttf")

var _completed: bool = false
var _catch_button: Button = null
var _time_label: Label = null
var _time_remaining: float = 0.0


func _ready() -> void:
	_time_remaining = time_limit
	_build_ui()
	_schedule_move()
	if time_limit > 0.0:
		var timer = get_tree().create_timer(time_limit)
		timer.timeout.connect(_on_timeout)


func _process(delta: float) -> void:
	if _completed:
		return
	_time_remaining -= delta
	if _time_label:
		_time_label.text = str(ceili(_time_remaining))


func _build_ui() -> void:
	var title = Label.new()
	title.text = "KIESZONKOWIEC!"
	title.add_theme_font_override("font", BUNGEE)
	title.add_theme_font_size_override("font_size", 80)
	title.add_theme_color_override("font_color", Color(0.9, 0.2, 0.1))
	title.add_theme_color_override("font_outline_color", Color.BLACK)
	title.add_theme_constant_override("outline_size", 6)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	title.offset_top = 40
	title.offset_bottom = 160
	add_child(title)

	var desc = Label.new()
	desc.text = "Złodziej sięga do Twojej kieszeni!\nZłap go zanim ucieknie!"
	desc.add_theme_font_override("font", BUNGEE)
	desc.add_theme_font_size_override("font_size", 36)
	desc.add_theme_color_override("font_outline_color", Color.BLACK)
	desc.add_theme_constant_override("outline_size", 4)
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	desc.offset_top = 160
	desc.offset_bottom = 310
	add_child(desc)

	_time_label = Label.new()
	_time_label.add_theme_font_override("font", BUNGEE)
	_time_label.add_theme_font_size_override("font_size", 96)
	_time_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
	_time_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_time_label.add_theme_constant_override("outline_size", 8)
	_time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_time_label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_time_label.offset_top = -130
	_time_label.offset_bottom = -20
	add_child(_time_label)

	_catch_button = Button.new()
	_catch_button.text = "ZŁAP!"
	_catch_button.add_theme_font_override("font", BUNGEE)
	_catch_button.add_theme_font_size_override("font_size", 42)
	_catch_button.size = Vector2(220, 110)
	_catch_button.position = Vector2(350, 380)
	_catch_button.pressed.connect(_on_catch)
	add_child(_catch_button)


func _schedule_move() -> void:
	if _completed:
		return
	var wait = get_tree().create_timer(randf_range(0.4, 1.2))
	wait.timeout.connect(_move_button)


func _move_button() -> void:
	if _completed or _catch_button == null:
		return
	var area = get_rect()
	var new_x = randf_range(30, area.size.x - 260)
	var new_y = randf_range(300, area.size.y - 170)

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(_catch_button, "position", Vector2(new_x, new_y), 0.35)

	_schedule_move()


func _on_catch() -> void:
	_finish({"accepted": true})


func _on_timeout() -> void:
	Global.player_hp = max(Global.player_hp - hp_penalty, 0)
	_finish({"accepted": false, "timeout": true, "hp_penalty": hp_penalty})


func _finish(result: Dictionary) -> void:
	if _completed:
		return
	_completed = true
	event_completed.emit(result)
