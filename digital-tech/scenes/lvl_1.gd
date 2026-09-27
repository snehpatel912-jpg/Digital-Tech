extends Node2D

func _ready():
	# Look for the dropoff node safely
	var dropoff_node = get_node_or_null("Quest/Dropoff")
	
	if dropoff_node != null:
		dropoff_node.game_finished.connect(_on_game_finished)
	else:
		push_error("Could not find the Dropoff node! Check your Scene Tree layout.")




func _on_game_finished(final_time: float):
	var stars = 0

	if final_time < 60:
		stars = 3
	elif final_time < 90:
		stars = 2
	elif final_time < 120:
		stars = 1
	else:
		stars = 0

	# Show final time
	$CanvasLayer/Panel/showcasingtime.text = format_time(final_time)

	# Show stars
	if stars == 3:
		$CanvasLayer/Panel/Stars.text = "★★★"
	elif stars == 2:
		$CanvasLayer/Panel/Stars.text = "★★☆"
	elif stars == 1:
		$CanvasLayer/Panel/Stars.text = "★☆☆"
	else:
		$CanvasLayer/Panel/Stars.text = "☆☆☆"

	# Show the panel
	$CanvasLayer/Panel.show()
	
	$CanvasLayer.process_mode= Node.PROCESS_MODE_ALWAYS

	# Stop the rest of the game
	get_tree().paused = true
	
func format_time(time: float) -> String:
	var minutes = int(time / 60)
	var seconds = int(time) % 60
	var milliseconds = int((time - int(time)) * 100)

	return "%02d:%02d.%02d" % [minutes, seconds, milliseconds]
	
