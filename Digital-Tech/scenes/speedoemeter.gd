extends Label


@export var target_node : taxi

func _process(_delta: float) -> void:
	if target_node:
		# 1. Get the raw velocity vector length (pixels per second)
		var raw_speed = target_node.velocity.length()
		
		# 2. Convert to an in-game "speed value" 
		# (Multiply by a scalar if you want it to look like km/h or mph)
		var scaled_speed = raw_speed * 0.1 
		
		# 3. Round the number and update the text
		text = str(round(scaled_speed)) + " KP/H"
	else:
		text = "0 KP/H"
