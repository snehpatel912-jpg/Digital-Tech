extends CharacterBody2D

@export var speed: float = 300.0
@export var rotation_speed: float = 2.5

func _physics_process(delta: float) -> void:
	# Up/Down controls forward and reverse
	var movement_input := Input.get_axis("ui_down", "ui_up")

	# Left/Right controls steering
	var turning_input := Input.get_axis("ui_left", "ui_right")

	# Only turn while the car is moving
	if movement_input != 0:
		rotation += turning_input * rotation_speed * delta * sign(movement_input)

	# Move in the direction the car is facing
	var forward_direction := Vector2.UP.rotated(rotation)
	velocity = forward_direction * movement_input * speed

	move_and_slide()
