extends Control

signal event_completed(result: Dictionary)

@export var time_limit: float = 25.0
@export var mole_timeout: float = 2.0
@export var hp_penalty_per_miss: int = 5

const BUNGEE = preload("res://assets/global/Bungee-Regular.ttf")
const HOLE_TEX = preload("res://assets/images/Hole.svg")
const MOLE_TEX = preload("res://assets/images/Mole.svg")

const HOLE_COUNT = 6
const COLS = 3
const MAX_HITS = 10

var _completed: bool = false
var _hiding: bool = false
var _active_hole: int = -1
var _mole_gen: int = 0
var _holes: Array = []
var _mole_node: TextureRect = null
var _time_label: Label = null
var _score_label: Label = null
var _time_remaining: float = 0.0
var _score: int = 0
var _hp_lost: int = 0


func _ready() -> void:
	_time_remaining = time_limit
	_build_ui()
	if time_limit > 0.0:
		get_tree().create_timer(time_limit).timeout.connect(_on_main_timeout)
	_schedule_mole()


func _process(delta: float) -> void:
	if _completed:
		return
	_time_remaining -= delta
	if _time_label:
		_time_label.text = str(ceili(_time_remaining))


func _build_ui() -> void:
	var title = Label.new()
	title.text = "UDERZ KRETA!"
	title.add_theme_font_override("font", BUNGEE)
	title.add_theme_font_size_override("font_size", 72)
	title.add_theme_color_override("font_color", Color(0.45, 0.28, 0.08))
	title.add_theme_color_override("font_outline_color", Color.BLACK)
	title.add_theme_constant_override("outline_size", 6)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	title.offset_top = 20
	title.offset_bottom = 120
	add_child(title)

	var hole_size = Vector2(220, 160)
	var spacing = Vector2(285, 240)
	var grid_w = COLS * spacing.x - (spacing.x - hole_size.x)
	var start_x = (860.0 - grid_w) / 2.0
	var start_y = 145.0

	for i in HOLE_COUNT:
		var col = i % COLS
		var row = i / COLS
		var pos = Vector2(start_x + col * spacing.x, start_y + row * spacing.y)

		var btn = TextureButton.new()
		btn.texture_normal = HOLE_TEX
		btn.layout_mode = 0
		btn.position = pos
		btn.size = hole_size
		btn.ignore_texture_size = true
		btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		btn.pressed.connect(_on_hole_clicked.bind(i))
		add_child(btn)
		_holes.append(btn)

	_score_label = Label.new()
	_score_label.text = "Trafień: 0/%d" % MAX_HITS
	_score_label.add_theme_font_override("font", BUNGEE)
	_score_label.add_theme_font_size_override("font_size", 42)
	_score_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_score_label.add_theme_constant_override("outline_size", 4)
	_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_score_label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_score_label.offset_top = -160
	_score_label.offset_bottom = -80
	add_child(_score_label)

	_time_label = Label.new()
	_time_label.add_theme_font_override("font", BUNGEE)
	_time_label.add_theme_font_size_override("font_size", 72)
	_time_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
	_time_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_time_label.add_theme_constant_override("outline_size", 8)
	_time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_time_label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_time_label.offset_top = -90
	_time_label.offset_bottom = -10
	add_child(_time_label)


func _schedule_mole() -> void:
	if _completed or _hiding:
		return

	var available = range(HOLE_COUNT).filter(func(i): return i != _active_hole)
	_active_hole = available[randi() % available.size()]
	_mole_gen += 1
	var gen = _mole_gen

	_show_mole(_active_hole)
	get_tree().create_timer(mole_timeout).timeout.connect(func(): _on_mole_timeout(gen))


func _show_mole(hole_idx: int) -> void:
	var hole = _holes[hole_idx]

	_mole_node = TextureRect.new()
	_mole_node.texture = MOLE_TEX
	_mole_node.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	_mole_node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_mole_node.size = hole.size
	_mole_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hole.add_child(_mole_node)

	_mole_node.pivot_offset = _mole_node.size / 2.0
	_mole_node.scale = Vector2.ZERO
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(_mole_node, "scale", Vector2.ONE, 0.18)


func _on_hole_clicked(idx: int) -> void:
	if _completed or idx != _active_hole or _hiding:
		return
	_mole_gen += 1
	_score += 1
	if _score_label:
		_score_label.text = "Trafień: %d/%d" % [_score, MAX_HITS]
	if _score >= MAX_HITS:
		_finish({"accepted": true, "score": _score, "hp_lost": _hp_lost})
		return
	_hide_mole_and_next()


func _on_mole_timeout(gen: int) -> void:
	if _completed or gen != _mole_gen:
		return
	_hp_lost += hp_penalty_per_miss
	Global.player_hp = max(Global.player_hp - hp_penalty_per_miss, 0)
	_hide_mole_and_next()


func _hide_mole_and_next() -> void:
	if _hiding:
		return
	_hiding = true
	_active_hole = -1

	var node_to_free = _mole_node
	_mole_node = null

	if node_to_free and is_instance_valid(node_to_free):
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_BACK)
		tween.set_ease(Tween.EASE_IN)
		tween.tween_property(node_to_free, "scale", Vector2.ZERO, 0.15)
		tween.tween_callback(node_to_free.queue_free)

	await get_tree().create_timer(0.3).timeout
	_hiding = false

	if not _completed:
		_schedule_mole()


func _on_main_timeout() -> void:
	_finish({"accepted": _score >= MAX_HITS, "score": _score, "hp_lost": _hp_lost})


func _finish(result: Dictionary) -> void:
	if _completed:
		return
	_completed = true
	if _mole_node and is_instance_valid(_mole_node):
		_mole_node.queue_free()
		_mole_node = null
	event_completed.emit(result)
