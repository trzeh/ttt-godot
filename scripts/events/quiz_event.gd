extends Control

signal event_completed(result: Dictionary)

@export var time_limit: float = 15.0
@export var hp_penalty: int = 30

const BUNGEE = preload("res://assets/global/Bungee-Regular.ttf")

const QUESTIONS = [
	{
		"question": "Jesteś na biegunie północnym.\nW którym kierunku nie możesz pójść?",
		"answers": ["Południe", "Wschód", "Zachód", "Północ"],
		"correct": 3
	},
	{
		"question": "Turysta pyta: która góra\njest najwyższa na świecie?",
		"answers": ["K2", "Mont Blanc", "Everest", "Kilimandżaro"],
		"correct": 2
	},
	{
		"question": "W jakim kraju leży miasto\n\"Ulaanbaatar\"?",
		"answers": ["Kazachstan", "Mongolia", "Chiny", "Rosja"],
		"correct": 1
	},
	{
		"question": "Ile krajów graniczy\nz Niemcami?",
		"answers": ["7", "8", "9", "6"],
		"correct": 2
	},
]

var _completed: bool = false
var _time_remaining: float = 0.0
var _time_label: Label = null
var _current_question: Dictionary = {}


func _ready() -> void:
	_time_remaining = time_limit
	_current_question = QUESTIONS[randi() % QUESTIONS.size()]
	_build_ui()
	if time_limit > 0.0:
		var t = get_tree().create_timer(time_limit)
		t.timeout.connect(_on_timeout)


func _process(delta: float) -> void:
	if _completed:
		return
	_time_remaining -= delta
	if _time_label:
		_time_label.text = str(ceili(_time_remaining))


func _build_ui() -> void:
	var title = Label.new()
	title.text = "TURYSTYCZNY QUIZ!"
	title.add_theme_font_override("font", BUNGEE)
	title.add_theme_font_size_override("font_size", 72)
	title.add_theme_color_override("font_color", Color(0.2, 0.6, 1.0))
	title.add_theme_color_override("font_outline_color", Color.BLACK)
	title.add_theme_constant_override("outline_size", 6)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	title.offset_top = 30
	title.offset_bottom = 140
	add_child(title)

	var question = Label.new()
	question.text = _current_question["question"]
	question.add_theme_font_override("font", BUNGEE)
	question.add_theme_font_size_override("font_size", 38)
	question.add_theme_color_override("font_outline_color", Color.BLACK)
	question.add_theme_constant_override("outline_size", 4)
	question.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	question.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	question.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	question.offset_top = 150
	question.offset_bottom = 320
	add_child(question)

	var answers: Array = _current_question["answers"]
	var correct_idx: int = _current_question["correct"]

	var btn_colors = [
		Color(0.9, 0.2, 0.2),
		Color(0.2, 0.7, 0.3),
		Color(0.2, 0.4, 0.9),
		Color(0.9, 0.7, 0.1),
	]

	for i in range(4):
		var btn = Button.new()
		btn.text = answers[i]
		btn.add_theme_font_override("font", BUNGEE)
		btn.add_theme_font_size_override("font_size", 34)
		btn.layout_mode = 0
		var col = i % 2
		var row = i / 2
		btn.position = Vector2(60 + col * 430, 350 + row * 160)
		btn.size = Vector2(390, 130)
		var is_correct = (i == correct_idx)
		btn.pressed.connect(_on_answer.bind(is_correct))
		add_child(btn)

	_time_label = Label.new()
	_time_label.add_theme_font_override("font", BUNGEE)
	_time_label.add_theme_font_size_override("font_size", 80)
	_time_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
	_time_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_time_label.add_theme_constant_override("outline_size", 8)
	_time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_time_label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_time_label.offset_top = -110
	_time_label.offset_bottom = -20
	add_child(_time_label)


func _on_answer(is_correct: bool) -> void:
	if is_correct:
		_finish({"accepted": true})
	else:
		Global.player_hp = max(Global.player_hp - hp_penalty, 0)
		_finish({"accepted": false, "wrong_answer": true})


func _on_timeout() -> void:
	Global.player_hp = max(Global.player_hp - hp_penalty, 0)
	_finish({"accepted": false, "timeout": true})


func _finish(result: Dictionary) -> void:
	if _completed:
		return
	_completed = true
	event_completed.emit(result)
