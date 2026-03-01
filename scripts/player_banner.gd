extends CanvasLayer

const BANNER_TEXTURE = preload("res://assets/global/PlayerBanner.svg")
const BUNGEE = preload("res://assets/global/Bungee-Regular.ttf")

var _banner: TextureRect = null
var _nick_label: Label = null
var _hp_label: Label = null
var _avatar_rect: TextureRect = null


func _ready() -> void:
	layer = 100
	_build_banner()
	hide_banner()


func _build_banner() -> void:
	_banner = TextureRect.new()
	_banner.texture = BANNER_TEXTURE
	_banner.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	_banner.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_banner.position = Vector2(20, 20)
	_banner.size = Vector2(500, 100)
	add_child(_banner)

	# Avatar area — left square of banner (roughly 165x149 in SVG, scaled to banner)
	_avatar_rect = TextureRect.new()
	_avatar_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_avatar_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_avatar_rect.position = Vector2(8, 8)
	_avatar_rect.size = Vector2(85, 85)
	_banner.add_child(_avatar_rect)

	# Nick label
	_nick_label = Label.new()
	_nick_label.add_theme_font_override("font", BUNGEE)
	_nick_label.add_theme_font_size_override("font_size", 28)
	_nick_label.add_theme_color_override("font_color", Color.WHITE)
	_nick_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_nick_label.add_theme_constant_override("outline_size", 4)
	_nick_label.position = Vector2(105, 10)
	_nick_label.size = Vector2(380, 40)
	_nick_label.clip_text = true
	_banner.add_child(_nick_label)

	# HP label — positioned next to the heart (heart is in SVG around x=214 → scaled ~134)
	_hp_label = Label.new()
	_hp_label.add_theme_font_override("font", BUNGEE)
	_hp_label.add_theme_font_size_override("font_size", 24)
	_hp_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
	_hp_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_hp_label.add_theme_constant_override("outline_size", 4)
	_hp_label.position = Vector2(155, 55)
	_hp_label.size = Vector2(200, 40)
	_banner.add_child(_hp_label)


func update_banner() -> void:
	if _nick_label:
		_nick_label.text = Global.player_name if Global.player_name != "" else "Gracz"
	if _hp_label:
		_hp_label.text = "%d/%d" % [Global.player_hp, Global.max_hp]
	_update_avatar()


func _update_avatar() -> void:
	if _avatar_rect == null:
		return
	if Global.player_avatar_base64 == "":
		return
	var png_bytes = Marshalls.base64_to_raw(Global.player_avatar_base64)
	var img = Image.new()
	var err = img.load_png_from_buffer(png_bytes)
	if err != OK:
		return
	_avatar_rect.texture = ImageTexture.create_from_image(img)


func show_banner() -> void:
	visible = true
	update_banner()


func hide_banner() -> void:
	visible = false


func show_damage(amount: int) -> void:
	if _banner == null:
		return
	var dmg_label = Label.new()
	dmg_label.text = "-%d" % amount
	dmg_label.add_theme_font_override("font", BUNGEE)
	dmg_label.add_theme_font_size_override("font_size", 36)
	dmg_label.add_theme_color_override("font_color", Color(1.0, 0.15, 0.1))
	dmg_label.add_theme_color_override("font_outline_color", Color.BLACK)
	dmg_label.add_theme_constant_override("outline_size", 5)
	dmg_label.position = Vector2(260, 40)
	dmg_label.z_index = 10
	_banner.add_child(dmg_label)
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(dmg_label, "position:y", -20, 1.0).set_ease(Tween.EASE_OUT)
	tween.tween_property(dmg_label, "modulate:a", 0.0, 1.0).set_delay(0.4)
	tween.chain().tween_callback(dmg_label.queue_free)
