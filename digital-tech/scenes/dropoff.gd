extends Area2D

@onready var stopwatch = get_tree().current_scene.get_node("Taxi/Camera2D/Control2")

signal game_finished

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Taxi":
		print("Item delivered successfully!")
		
		var final_time = stopwatch.stop_stopwatch()
		
		game_finished.emit(final_time)
