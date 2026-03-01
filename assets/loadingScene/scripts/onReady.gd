extends Control

const TEXT_SCENE = preload("res://assets/text.tscn")

var speed = 420.0
@onready var elevator = $elevator
@onready var levelFloorSprite = $levelFloorSprite
@onready var mainSprite = $mainSprite

var doors_opened = false
var _elevator_arrived = false
var _level_label: Label = null


func _ready() -> void:
	PlayerBanner.show_banner()


func _process(delta: float) -> void:
	if elevator.position.y != 178.0:
		elevator.position.y = move_toward(elevator.position.y, 178.0, speed * delta)
	elif not _elevator_arrived:
		_elevator_arrived = true
		_show_level_label()

	if elevator.position.y >= 149.0:
		if levelFloorSprite.position.y != 0.0:
			levelFloorSprite.position.y = move_toward(levelFloorSprite.position.y, 0, speed * delta)

		if mainSprite.position.y != -1920.0:
			mainSprite.position.y = move_toward(mainSprite.position.y, -1920, speed * delta)

	if mainSprite.position.y <= -1920 and not doors_opened:
		doors_opened = true
		elevator.open_doors()
		_fade_out_label()


func _show_level_label() -> void:
	_level_label = TEXT_SCENE.instantiate()
	_level_label.text = "Poziom: %d" % LevelManager.current_level
	_level_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_level_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(_level_label)


func _fade_out_label() -> void:
	if _level_label == null:
		return
	var tween = create_tween()
	tween.tween_property(_level_label, "modulate:a", 0.0, 1.0)
	tween.tween_callback(func():
		_level_label.queue_free()
		LevelManager.trigger_random_event()
	)


func play_exit() -> void:
	set_process(false)

	elevator.toggle_doors()

	await get_tree().create_timer(elevator.animation_time + 0.1).timeout

	var tween = create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(elevator, "position:y", 1300, 1.2)
	tween.tween_property(levelFloorSprite, "position:y", -1080, 1.2)

	await tween.finished

	get_tree().change_scene_to_file("res://scenes/Loading.tscn")
