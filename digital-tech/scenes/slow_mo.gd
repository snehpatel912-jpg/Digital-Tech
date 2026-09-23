extends Node

@export var normal_speed: float = 1.0
@export var slow_mo_speed: float = 0.1   # 10% speed
@export var lerp_weight: float = 0.2     # Controls how fast time ramps up/down

func _process(_delta: float) -> void:
	# Check if the slow_mo button is actively being held down
	if Input.is_action_pressed("slow_mo"):
		# Smoothly drop time to slow motion
		Engine.time_scale = lerp(Engine.time_scale, slow_mo_speed, lerp_weight)
	else:
		# Smoothly return to normal speed when released
		Engine.time_scale = lerp(Engine.time_scale, normal_speed, lerp_weight)
