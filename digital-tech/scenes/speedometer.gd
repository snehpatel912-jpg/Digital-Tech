extends Label

@export var target_body: CharacterBody2D

const PIXELS_TO_KMH = 0.036

func _process(delta: float) -> void:
	if target_body:
		var speed_pixels_per_sec = target_body.velocity.length()
		
		var speed_kmh = speed_pixels_per_sec * PIXELS_TO_KMH
		
		text = str(round(speed_kmh)) + " Km/h"
	else:
		text = " 0 Km/h"
		
