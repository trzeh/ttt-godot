extends Control

signal event_completed(result: Dictionary)

@export var time_limit: float = 8.0
@export var hp_penalty: int = 35
@export var clicks_needed: int = 20

const BUNGEE = preload("res://assets/global/Bungee-Regular.ttf")

var _completed: bool = false
var _click_count: int = 0
var _time_remaining: float = 0.0
var _time_label: Label = null
var _counter_label: Label = null
var _progress_bar: ProgressBar = null


func _ready() -> void:
	_time_remaining = time_limit
	_build_ui()
	if time_limit > 0.0:
		var t = get_tree().create_timer(time_limit)
		t.timeout.connect(_on_timeout)


func _process(delta: float) -> void:
	if _completed:
		return
	_time_remaining -= delta
	if _time_label:
		_time_label.text = "%.1f" % maxf(_time_remaining, 0.0)


func _build_ui() -> void:
	var title = Label.new()
	title.text = "LAWINA KAMIENI!"
	title.add_theme_font_override("font", BUNGEE)
	title.add_theme_font_size_override("font_size", 80)
	title.add_theme_color_override("font_color", Color(0.8, 0.4, 0.1))
	title.add_theme_color_override("font_outline_color", Color.BLACK)
	title.add_theme_constant_override("outline_size", 6)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	title.offset_top = 30
	title.offset_bottom = 140
	add_child(title)

	var desc = Label.new()
	desc.text = "Klikaj jak najszybciej!\nOdepnij głazy zanim zgniotą turystów!"
	desc.add_theme_font_override("font", BUNGEE)
	desc.add_theme_font_size_override("font_size", 34)
	desc.add_theme_color_override("font_outline_color", Color.BLACK)
	desc.add_theme_constant_override("outline_size", 4)
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	desc.offset_top = 150
	desc.offset_bottom = 290
	add_child(desc)

	_progress_bar = ProgressBar.new()
	_progress_bar.max_value = clicks_needed
	_progress_bar.value = 0
	_progress_bar.layout_mode = 0
	_progress_bar.position = Vector2(80, 310)
	_progress_bar.size = Vector2(750, 50)
	add_child(_progress_bar)

	_counter_label = Label.new()
	_counter_label.text = "0 / %d" % clicks_needed
	_counter_label.add_theme_font_override("font", BUNGEE)
	_counter_label.add_theme_font_size_override("font_size", 42)
	_counter_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_counter_label.add_theme_constant_override("outline_size", 4)
	_counter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_counter_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_counter_label.offset_top = 370
	_counter_label.offset_bottom = 460
	add_child(_counter_label)

	var mash_btn = Button.new()
	mash_btn.text = "ODPYCHAJ!"
	mash_btn.add_theme_font_override("font", BUNGEE)
	mash_btn.add_theme_font_size_override("font_size", 52)
	mash_btn.layout_mode = 0
	mash_btn.position = Vector2(160, 490)
	mash_btn.size = Vector2(580, 160)
	mash_btn.pressed.connect(_on_mash)
	add_child(mash_btn)

	_time_label = Label.new()
	_time_label.add_theme_font_override("font", BUNGEE)
	_time_label.add_theme_font_size_override("font_size", 72)
	_time_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
	_time_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_time_label.add_theme_constant_override("outline_size", 8)
	_time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_time_label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_time_label.offset_top = -110
	_time_label.offset_bottom = -20
	add_child(_time_label)


func _on_mash() -> void:
	_click_count += 1
	_progress_bar.value = _click_count
	_counter_label.text = "%d / %d" % [_click_count, clicks_needed]

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(_progress_bar, "scale", Vector2(1.0, 1.3), 0.05)
	tween.tween_property(_progress_bar, "scale", Vector2.ONE, 0.1)

	if _click_count >= clicks_needed:
		_finish({"accepted": true})


func _on_timeout() -> void:
	Global.player_hp = max(Global.player_hp - hp_penalty, 0)
	_finish({"accepted": false, "timeout": true, "hp_penalty": hp_penalty})


func _finish(result: Dictionary) -> void:
	if _completed:
		return
	_completed = true
	event_completed.emit(result)
