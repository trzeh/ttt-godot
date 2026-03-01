extends Control

var speed = 420.0
@onready var elevator = $elevator
@onready var levelFloorSprite = $levelFloorSprite
@onready var mainSprite = $mainSprite

var doors_opened = false

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if elevator.position.y != 178.0:
		elevator.position.y = move_toward(elevator.position.y, 178.0, speed * delta)
	
	if elevator.position.y >= 149.0:
		if levelFloorSprite.position.y != 0.0:
			levelFloorSprite.position.y = move_toward(levelFloorSprite.position.y, 0, speed * delta)
			
		if mainSprite.position.y != -1920.0:
			mainSprite.position.y = move_toward(mainSprite.position.y, -1920, speed * delta)
		
	if mainSprite.position.y <= -1920 and not doors_opened:
		elevator.open_doors()
		doors_opened = true
