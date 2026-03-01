extends Node

signal profile_ready

@onready var nick_input = %nickInput
@onready var canvas = %canvas

func _on_next_button_pressed():
	Global.player_name = nick_input.text if nick_input.text != "" else "Gracz"
	Global.player_hp = 100
	
	if canvas and "lines" in canvas:
		Global.player_avatar_data = canvas.lines.duplicate(true)
	
	_capture_avatar_base64()
	profile_ready.emit()

func _capture_avatar_base64():
	if canvas == null:
		return
	await RenderingServer.frame_post_draw
	var img = get_viewport().get_texture().get_image()
	var canvas_rect = canvas.get_global_rect()
	var cropped = img.get_region(Rect2i(canvas_rect))
	cropped.resize(128, 128)
	
	# Make white/near-white pixels transparent, keep only drawn lines
	for y in range(cropped.get_height()):
		for x in range(cropped.get_width()):
			var pixel = cropped.get_pixel(x, y)
			if pixel.r > 0.85 and pixel.g > 0.85 and pixel.b > 0.85:
				cropped.set_pixel(x, y, Color(0, 0, 0, 0))
	
	var png_bytes = cropped.save_png_to_buffer()
	Global.player_avatar_base64 = Marshalls.raw_to_base64(png_bytes)

