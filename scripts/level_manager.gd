extends Node

var current_level: int = 1

const BACKGROUND = preload("res://assets/serverGui/background.svg")

var _event_scripts: Array[Script] = []
var _last_event_script: Script = null


func _ready() -> void:
	register_event("res://scripts/events/example_event.gd")
	register_event("res://scripts/events/quiz_event.gd")
	register_event("res://scripts/events/mash_event.gd")
	register_event("res://scripts/events/mole_event.gd")


func register_event(script_path: String) -> void:
	var s = load(script_path)
	if s:
		_event_scripts.append(s)
	else:
		push_warning("LevelManager: nie można załadować skryptu: " + script_path)


func trigger_random_event() -> void:
	if _event_scripts.is_empty():
		push_warning("LevelManager: brak zarejestrowanych eventów")
		return

	var available = _event_scripts.filter(func(s): return s != _last_event_script)
	if available.is_empty():
		available = _event_scripts

	var script = available[randi() % available.size()]
	_last_event_script = script
	_launch_event_script(script)


func _launch_event_script(event_script: Script) -> void:
	var wrapper = Control.new()
	wrapper.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var bg = TextureRect.new()
	bg.texture = BACKGROUND
	bg.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	bg.layout_mode = 1
	bg.anchor_left = 0.05
	bg.anchor_top = 0.05
	bg.anchor_right = 0.05
	bg.anchor_bottom = 0.05
	bg.offset_left = 16
	bg.offset_top = -5
	bg.offset_right = 1744
	bg.offset_bottom = 967
	bg.grow_horizontal = Control.GROW_DIRECTION_BOTH
	bg.grow_vertical = Control.GROW_DIRECTION_BOTH
	wrapper.add_child(bg)

	var event_node = Control.new()
	event_node.set_script(event_script)
	event_node.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.add_child(event_node)

	get_tree().current_scene.add_child(wrapper)

	var screen_size = get_viewport().get_visible_rect().size
	wrapper.pivot_offset = screen_size / 2.0
	wrapper.scale = Vector2.ZERO

	var tween = get_tree().current_scene.create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(wrapper, "scale", Vector2.ONE, 0.4)

	if event_node.has_signal("event_completed"):
		await get_tree().process_frame
		event_node.event_completed.connect(func(result):
			_on_event_completed(result, wrapper)
		)


func _on_event_completed(result: Dictionary, wrapper: Control) -> void:
	print("Event zakończony: ", result)
	var screen_size = get_viewport().get_visible_rect().size
	wrapper.pivot_offset = screen_size / 2.0

	var tween = get_tree().current_scene.create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(wrapper, "scale", Vector2.ZERO, 0.3)
	tween.tween_callback(func():
		wrapper.queue_free()
		current_level += 1
		var scene = get_tree().current_scene
		if scene.has_method("play_exit"):
			scene.play_exit()
		else:
			get_tree().change_scene_to_file("res://scenes/Loading.tscn")
	)
