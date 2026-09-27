extends Node2D
var master_volume_slider = AudioServer.get_bus_index("Master")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
		get_tree().change_scene_to_file("res://scenes/mainmenu.tscn") 	
		
func _on_master_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(master_volume_slider, linear_to_db(value))
	
