extends Node

signal connected_to_lobby(data)
signal connection_failed(reason)
signal message_received(type, data)

var socket := WebSocketPeer.new()
var is_authenticated := false
var player_info := {}
var lobby_info := {}

const WSS_URL = "ws://127.0.0.1:8080/game/"

func _process(_delta):
	socket.poll()
	
	var state = socket.get_ready_state()
	
	if state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count() > 0:
			var packet = socket.get_packet()
			_on_data_received(packet.get_string_from_utf8())
			
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = socket.get_close_code()
		var reason = socket.get_close_reason()
		print("Połączenie zamknięte: %d, powód: %s" % [code, reason])
		set_process(false)

func connect_to_game(mode: String, nick: String, avatar: String, lobby_id: String = ""):
	is_authenticated = false
	var url = WSS_URL + mode
	
	var err = socket.connect_to_url(url)
	if err != OK:
		connection_failed.emit("Nie można zainicjować połączenia")
		return

	player_info = {"nick": nick, "avatar": avatar}
	if mode == "join":
		player_info["lobbyId"] = lobby_id
	
	set_process(true)

func _on_data_received(data_str: String):
	var json = JSON.parse_string(data_str)
	if json == null: return
	
	if not is_authenticated:
		_send_auth_packet()
		is_authenticated = true
	
	if json.get("type") == "auth" and json.get("success") == true:
		player_info = json.get("player")
		lobby_info = json.get("lobby")
		connected_to_lobby.emit(json)
	
	message_received.emit(json.get("type"), json)

func _send_auth_packet():
	var json_string = JSON.stringify(player_info)
	socket.send_text(json_string)
