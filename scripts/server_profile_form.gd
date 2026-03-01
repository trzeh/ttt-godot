extends Control

@onready var nick_input = $demo/background/nickInput
@onready var canvas = $demo/background/avatarArea/canvas
@onready var demo_popup = $demo
@onready var blur_rect = $mainmenu/blur
@onready var main_ui_elements = [$mainmenu/title, $mainmenu/Control, $mainmenu/Control2]

func _on_next_button_pressed():
	save_player_profile()
	
	var tween = create_tween().set_parallel(true)
	
	tween.tween_property(demo_popup, "modulate:a", 0.0, 0.5)
	tween.tween_property(blur_rect, "modulate:a", 0.0, 1.0)
	
	for element in main_ui_elements:
		tween.tween_property(element, "modulate:a", 0.0, 0.8)
	
	tween.chain().tween_callback(demo_popup.queue_free)

func save_player_profile():
	Global.player_name = nick_input.text if nick_input.text != "" else "Nieznajomy"
	Global.player_hp = 100
	
	var img = get_viewport().get_texture().get_image()
	var canvas_rect = canvas.get_global_rect()
	Global.player_avatar = img.get_region(canvas_rect)
