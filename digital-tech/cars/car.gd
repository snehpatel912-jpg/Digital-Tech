extends CharacterBody2D


@export var engine_power = 1000
@export var friction: float = 0.5
@export var drag: float = -0.06
@export var braking = -450
@export var max_speed_reverse = 250
@export var slip_speed = 400
@export var traction_fast = 2.5
@export var traction_slow = 10
@export var steering_angle: float = 30.0
var wheel_base = 65
var acceleration = Vector2.ZERO
var steer_direction
var normal_traction = 0.9  
var drift_traction = 0.98  
var speed = -10
var handbrake_angle = 0.0

@export var is_active = false



func physics_process(delta: float) -> void:
	if is_active:
		$Camera2D.enabled = true
		acceleration = Vector2.ZERO
		get_input()
		calculate_steering(delta)
	else:
		$Camera2D.enabled = false
		
	velocity += acceleration * delta
	apply_friction(delta)
	move_and_slide()
		
	

func _physics_process(delta: float) -> void:
	acceleration = Vector2.ZERO
	get_input()
	apply_friction(delta)
	calculate_steering(delta)
	velocity += acceleration * delta
	
	
	
	var is_handbrake = Input.is_action_pressed("handbrake")
	
	var current_traction = drift_traction if is_handbrake else normal_traction
	
	var forward_velocity = transform.x * transform.x.dot(velocity)
	var lateral_velocity = transform.y * transform.y.dot(velocity)
	
	velocity = forward_velocity + lateral_velocity.lerp(Vector2.ZERO, 1.0 - current_traction)
	
	move_and_slide()


func get_input():
	var turn = Input.get_axis("ui_left","ui_right")
	steer_direction = turn * deg_to_rad(steering_angle)
	
	if Input.is_action_pressed("ui_up"):
		acceleration = transform.x * engine_power
		
	if Input.is_action_pressed("ui_down"):
		acceleration = transform.x * braking
		
	
func apply_friction(delta):
	if acceleration == Vector2.ZERO and velocity.length() < 50:
		velocity = Vector2.ZERO
	var friction_force = velocity * friction * delta
	var drag_force = velocity * velocity.length() * drag * delta
	
	acceleration += drag_force + friction_force 
	
func calculate_steering(delta):
		var rear_wheel = position - transform.x * wheel_base / 2.0
		var front_wheel = position + transform.x * wheel_base / 2.0
		
		rear_wheel += velocity * delta
		front_wheel += velocity.rotated(steer_direction) * delta
		
		var new_heading = rear_wheel.direction_to(front_wheel)
		
		var traction = traction_slow
		if velocity.length() > slip_speed:
			traction = traction_fast
			
		var d = new_heading.dot(velocity.normalized())
		
		if d > 0:
			velocity = lerp(velocity, new_heading * velocity.length(), traction * delta)
			
		if d < 0: 
			velocity = -new_heading * min(velocity.length(), max_speed_reverse)
			
		rotation = new_heading.angle()
		


func _on_collectionplace_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_dropoff_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
