extends Control

@onready var nick_input = $nickInput # Załóżmy, że masz pola tekstowe
@onready var avatar_id = "warrior_1"

func _on_create_button_pressed():
	var nick = nick_input.text
	if nick.is_empty(): return
	
	# Wywołujemy Autoload
	Network.connect_to_game("create", nick, avatar_id)

func _ready():
	# Nasłuchujemy na sukces połączenia
	Network.connected_to_lobby.connect(_on_lobby_created)

func _on_lobby_created(data):
	print("Lobby utworzone! ID: ", data.lobby.id)
	# Tutaj zmień scenę na poczekalnię lub grę
	# get_tree().change_scene_to_file("res://scenes/lobby.tscn")
