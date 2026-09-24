extends Control

@onready var label: Label = $StopwatchLabel

var time_elapsed: float = 0.0
var is_running: bool = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_running:
		time_elapsed += delta
		update_stopwatch_display()
		
func update_stopwatch_display() -> void:
	var minutes: int = int(time_elapsed / 60)
	var seconds: int = int(time_elapsed) % 60
	var milliseconds: int = int((time_elapsed - int(time_elapsed)) * 100)
	
	label.text = "%02d:%02d.%02d" % [minutes, seconds, milliseconds]
	
func stop_stopwatch() -> void:
	is_running = false

func start_stopwatch() -> void:
	is_running = true

func reset_stopwatch() -> void:
	time_elapsed = 0.0
	update_stopwatch_display()



	
		
		
