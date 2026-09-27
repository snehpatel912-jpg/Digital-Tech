extends CharacterBody2D

@export var player_hitbox:CharacterBody2D
@export var friction: float = 0.5 #Ground surface resistance
@export var drag: float = -0.06 #air resistance
@export var slip_speed = 400 #the speed where tires start losing grip
@export var traction_fast = 2.5 #made for sliding and drifitng at hgih speeds
@export var traction_slow = 10 #grip responsivness at low speeds
@export var steering_angle: float = 30.0 #maximum turn radius
var wheel_base = 65 #distance between front and rear axel
var acceleration = Vector2.ZERO #linear acceleration
var steer_direction # wheel angle in radians
var normal_traction = 0.9 # normal grip  
var drift_traction = 0.98  # sideways grip when handbrake is on
var speed = -10 # baseline variable
var handbrake_angle = 0.0 # variable for custom turn dampening 
var police_damage = 10 # damage from the police
var killed = 0 # health when car dies

@export var is_active = false #flag if players inputs are active or not

@export_category("Player Stats")
@export var engine_power = 1000 # maximum froward drive force
@export var braking = -450 # reverse and braking force
@export var max_speed_reverse = 250 # maximum reverse speed
@export var health = 100 # max health for the plater




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
		
	
## Standard engine loop method executed at a fixed framerate (typically 60Hz).
## Manages global vector applications, local vector decomposition for drifts, and sliding execution.
func _physics_process(delta: float) -> void:
	# Clean slate acceleration value before reading fresh context inputs
	acceleration = Vector2.ZERO
	get_input()
	apply_friction(delta)
	calculate_steering(delta)
	velocity += acceleration * delta
	
	
	# Determine drift modifier state
	var is_handbrake = Input.is_action_pressed("handbrake")
	var current_traction = drift_traction if is_handbrake else normal_traction
	
	# Project raw global velocity onto the vehicle's structural local coordinate axes (forward/lateral)
	var forward_velocity = transform.x * transform.x.dot(velocity)
	var lateral_velocity = transform.y * transform.y.dot(velocity)
	
	# Reduce sideways velocity over time to mimic tire traction gripping the pavement
	velocity = forward_velocity + lateral_velocity.lerp(Vector2.ZERO, 1.0 - current_traction)
	
	move_and_slide()


func get_input():
	var turn = Input.get_axis("ui_left","ui_right") # basically looking at your inputs to turn
	steer_direction = turn * deg_to_rad(steering_angle)
	
	if Input.is_action_pressed("ui_up"): #going forward
		acceleration = transform.x * engine_power
		
	if Input.is_action_pressed("ui_down"): #going backwards and braking input
		acceleration = transform.x * braking
		
	
func apply_friction(delta):
	# stops crawl values 
	if acceleration == Vector2.ZERO and velocity.length() < 50:
		velocity = Vector2.ZERO
	# computes linear scale values	
	var friction_force = velocity * friction * delta
	# computes exponential scaling structural drag
	var drag_force = velocity * velocity.length() * drag * delta
	# Layer enviromental calculations
	acceleration += drag_force + friction_force 
	
func calculate_steering(delta):
	# pivot indicators 
		var rear_wheel = position - transform.x * wheel_base / 2.0
		var front_wheel = position + transform.x * wheel_base / 2.0
		# coordinate properties into frametime 
		rear_wheel += velocity * delta
		front_wheel += velocity.rotated(steer_direction) * delta
		#map vectors
		var new_heading = rear_wheel.direction_to(front_wheel)
		# scale responsivness based on movement
		var traction = traction_slow
		if velocity.length() > slip_speed:
			traction = traction_fast
		#assess whether vehicle is executing forward or reverse metrics
		var d = new_heading.dot(velocity.normalized())
		#forward updates
		if d > 0:
			velocity = lerp(velocity, new_heading * velocity.length(), traction * delta)
		# reverse updates
		if d < 0: 
			velocity = -new_heading * min(velocity.length(), max_speed_reverse)
			
		rotation = new_heading.angle()
		

# trigger entry when car enters and leaves
func _on_collectionplace_body_entered(body: Node2D) -> void:
	pass 
# triggers entry when car enters

func _on_dropoff_body_entered(body: Node2D) -> void:
	pass 
	
