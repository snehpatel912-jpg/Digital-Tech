extends Node2D
var master_volume_slider = AudioServer.get_bus_index("Master")
var slider_value: float = 50.0
# Called when the node enters the scene tree for the first time.


func _ready() -> void:
	$MasterVolumeSlider.value = settings.slider_value
	$MasterVolumeSlider.value_changed.connect(_on_master_volume_slider_value_changed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
		get_tree().change_scene_to_file("res://scenes/mainmenu.tscn") 	
		
func _on_master_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(master_volume_slider, linear_to_db(value) )
	
	settings.slider_value = value
