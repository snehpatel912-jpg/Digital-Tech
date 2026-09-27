extends ProgressBar


@export var taxi : Node2D

func _ready() -> void:
	if taxi:
		max_value = taxi.max_health
		value = taxi.current_health
		# Connect to a custom health_changed signal from your player
		taxi.health_changed.connect(_on_player_health_changed)

func _on_player_health_changed(current_health: int) -> void:
	value = current_health
