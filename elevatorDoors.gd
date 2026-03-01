extends TextureRect 

@export var slide_left: Vector2 = Vector2(-25, 25)
@export var slide_right: Vector2 = Vector2(20, -20)

@export var height_change_left: float = 30.0
@export var height_change_right: float = -20.0

@export var animation_time: float = 0.5 

@onready var doors_left = $doorsLeft
@onready var doors_right = $doorsRight

var is_open: bool = false

var left_closed_pos: Vector2
var right_closed_pos: Vector2
var left_closed_size: Vector2
var right_closed_size: Vector2

func _ready():
	left_closed_pos = doors_left.position
	right_closed_pos = doors_right.position
	left_closed_size = doors_left.size
	right_closed_size = doors_right.size

# Zwykły toggle - włącza/wyłącza drzwi
func toggle_doors():
	is_open = !is_open 
	var tween = create_tween()
	
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	if is_open:
		var l_open_pos = left_closed_pos + slide_left + Vector2(0, -height_change_left)
		var l_open_size = left_closed_size + Vector2(0, height_change_left)
		
		var r_open_pos = right_closed_pos + slide_right + Vector2(0, -height_change_right)
		var r_open_size = right_closed_size + Vector2(0, height_change_right)
		
		tween.tween_property(doors_left, "position", l_open_pos, animation_time)
		tween.tween_property(doors_left, "size", l_open_size, animation_time)
		tween.tween_property(doors_left, "modulate:a", 0.0, animation_time)
		
		tween.tween_property(doors_right, "position", r_open_pos, animation_time)
		tween.tween_property(doors_right, "size", r_open_size, animation_time)
		tween.tween_property(doors_right, "modulate:a", 0.0, animation_time)
	else:
		tween.tween_property(doors_left, "position", left_closed_pos, animation_time)
		tween.tween_property(doors_left, "size", left_closed_size, animation_time)
		tween.tween_property(doors_left, "modulate:a", 1.0, animation_time)
		
		tween.tween_property(doors_right, "position", right_closed_pos, animation_time)
		tween.tween_property(doors_right, "size", right_closed_size, animation_time)
		tween.tween_property(doors_right, "modulate:a", 1.0, animation_time)

# NOWA funkcja - gwarantuje, że drzwi TYLKO się otworzą (wykorzystywana przez główny skrypt)
func open_doors():
	if not is_open:
		toggle_doors()

# Wciskanie klawisza - zostaje po staremu, używa toggle
func _input(event):
	if event.is_action_pressed("ui_accept"): 
		toggle_doors()
