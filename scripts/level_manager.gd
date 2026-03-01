extends Node

var current_level: int = 1
@export var events: Array[PackedScene] = []

const BACKGROUND = preload("res://assets/serverGui/background.svg")

func _ready() -> void:
	pass

func pick_random_event() -> PackedScene:
	if events.is_empty():
		push_warning("LevelManager: brak eventów na liście")
		return null
	return events[randi() % events.size()]

func trigger_random_event() -> void:
	var event_scene = pick_random_event()
	if event_scene == null:
		return
	launch_event(event_scene)

func launch_event(event_scene: PackedScene) -> void:
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

	var event_content = event_scene.instantiate()
	event_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.add_child(event_content)

	get_tree().current_scene.add_child(wrapper)

	var screen_size = get_viewport().get_visible_rect().size
	wrapper.pivot_offset = screen_size / 2.0
	wrapper.scale = Vector2.ZERO

	var tween = get_tree().current_scene.create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(wrapper, "scale", Vector2.ONE, 0.4)

	if event_content.has_signal("event_completed"):
		event_content.event_completed.connect(func(result):
			_on_event_completed(result, wrapper)
		)

func _on_event_completed(result: Dictionary, wrapper: Control) -> void:
	print("Event zakończony, wynik: ", result)
	var screen_size = get_viewport().get_visible_rect().size
	wrapper.pivot_offset = screen_size / 2.0

	var tween = get_tree().current_scene.create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(wrapper, "scale", Vector2.ZERO, 0.3)
	tween.tween_callback(wrapper.queue_free)
