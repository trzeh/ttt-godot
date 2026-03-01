extends Control 
# Ta zmienna pozwoli Ci przeciągnąć plik .tscn prosto do Inspektora!
@export var next_scene: PackedScene 

# To jest funkcja, która wygenerowała się po podłączeniu sygnału pressed()
func _on_create_button_pressed():
	if next_scene != null:
		# Zmieniamy obecną scenę na tę załadowaną w Inspektorze
		get_tree().change_scene_to_packed(next_scene)
	else:
		print("Ups! Zapomniałeś przypisać scenę do załadowania w Inspektorze.")


func _on_pressed() -> void:
	if next_scene != null:
		# Zmieniamy obecną scenę na tę załadowaną w Inspektorze
		get_tree().change_scene_to_packed(next_scene)
	else:
		print("Ups! Zapomniałeś przypisać scenę do załadowania w Inspektorze.")
