extends Node

var current_level: int = 1

const BACKGROUND = preload("res://assets/serverGui/background.svg")

var _event_scripts: Array[Script] = []
var _last_event_script: Script = null
var _hp_before_event: int = 100


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
		_hp_before_event = Global.player_hp
		await get_tree().process_frame
		event_node.event_completed.connect(func(result):
			_on_event_completed(result, wrapper)
		)


func _on_event_completed(result: Dictionary, wrapper: Control) -> void:
	print("Event zakończony: ", result)
	
	var accepted = result.get("accepted", false)
	
	if not accepted:
		var level_penalty = 3 * current_level
		Global.player_hp = max(Global.player_hp - level_penalty, 0)
	
	var total_damage = _hp_before_event - Global.player_hp
	PlayerBanner.update_banner()
	if total_damage > 0:
		PlayerBanner.show_damage(total_damage)
	
	_flash_screen(Color(0.1, 0.9, 0.2, 0.35) if accepted else Color(0.9, 0.1, 0.1, 0.35))
	var screen_size = get_viewport().get_visible_rect().size
	wrapper.pivot_offset = screen_size / 2.0

	var tween = get_tree().current_scene.create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(wrapper, "scale", Vector2.ZERO, 0.3)
	tween.tween_callback(func():
		wrapper.queue_free()
		if Global.player_hp <= 0:
			_trigger_game_over()
			return
		current_level += 1
		var scene = get_tree().current_scene
		if scene.has_method("play_exit"):
			scene.play_exit()
		else:
			get_tree().change_scene_to_file("res://scenes/Loading.tscn")
	)


func _trigger_game_over() -> void:
	var game_over_script = load("res://scripts/game_over.gd")
	var game_over = CanvasLayer.new()
	game_over.set_script(game_over_script)
	get_tree().current_scene.add_child(game_over)


func _flash_screen(color: Color) -> void:
	var flash = ColorRect.new()
	flash.color = color
	flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	get_tree().current_scene.add_child(flash)
	
	flash.modulate = Color(1, 1, 1, 0)
	var tween = get_tree().current_scene.create_tween()
	tween.tween_property(flash, "modulate:a", 1.0, 0.12)
	tween.tween_property(flash, "modulate:a", 0.0, 0.4)
	tween.tween_callback(flash.queue_free)
