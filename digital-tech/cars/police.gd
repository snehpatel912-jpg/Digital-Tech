extends CharacterBody2D

enum State {
	PATROL,
	CHASE,
	SEARCH
}

@export_category("References")
@export var taxi: CharacterBody2D
@export var patrol_points_parent: Node2D

@export_category("Movement")
@export var patrol_speed: float = 140.0
@export var chase_speed: float = 230.0
@export var turn_speed: float = 4.0

@export_category("Vision")
@export var view_distance: float = 1000.00
@export var view_angle: float = 400.00
@export var chase_memory: float = 10.0

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var vision_ray: RayCast2D = $RayCast2D

var current_state: State = State.PATROL

var patrol_points: Array[Marker2D] = []

var last_seen_position: Vector2
var memory_timer: float = 0.0
var repath_timer: float = 0.0

var stuck_timer: float = 0.0
var previous_position: Vector2


func _ready() -> void:
	previous_position = global_position

	# Find all the Marker2D patrol points.
	if patrol_points_parent != null:
		for child in patrol_points_parent.get_children():
			if child is Marker2D:
				patrol_points.append(child)

	# Navigation needs a physics frame to become ready.
	await get_tree().physics_frame

	_choose_random_patrol_point()


func _physics_process(delta: float) -> void:
	if taxi == null:
		velocity = Vector2.ZERO
		return

	var taxi_visible := _can_see_taxi()

	if taxi_visible:
		current_state = State.CHASE
		last_seen_position = taxi.global_position
		memory_timer = chase_memory

		# Update the chase path several times per second.
		repath_timer -= delta

		if repath_timer <= 0.0:
			navigation_agent.target_position = taxi.global_position
			repath_timer = 0.15

	elif current_state == State.CHASE:
		memory_timer -= delta

		if memory_timer <= 0.0:
			current_state = State.SEARCH
			navigation_agent.target_position = last_seen_position

	match current_state:
		State.PATROL:
			if navigation_agent.is_navigation_finished():
				_choose_random_patrol_point()

		State.CHASE:
			pass

		State.SEARCH:
			if navigation_agent.is_navigation_finished():
				current_state = State.PATROL
				_choose_random_patrol_point()

	_follow_path(delta)
	_check_if_stuck(delta)


func _can_see_taxi() -> bool:
	var direction_to_taxi := taxi.global_position - global_position
	var distance_to_taxi := direction_to_taxi.length()

	# Taxi is too far away.
	if distance_to_taxi > view_distance:
		return false

	# This assumes the cop faces upward.
	var forward_direction := Vector2.UP.rotated(rotation)
	var angle_to_taxi: float = absf(
	forward_direction.angle_to(direction_to_taxi.normalized())
	)

	# Taxi is outside the police car's field of view.
	if angle_to_taxi > deg_to_rad(view_angle / 2.0):
		return false

	# Check whether a building is blocking the view.
	vision_ray.target_position = vision_ray.to_local(taxi.global_position)
	vision_ray.force_raycast_update()

	if not vision_ray.is_colliding():
		return false

	return vision_ray.get_collider() == taxi


func _choose_random_patrol_point() -> void:
	if patrol_points.is_empty():
		push_warning("No patrol Marker2D nodes have been assigned.")
		return

	var selected_point: Marker2D = patrol_points.pick_random() as Marker2D
	navigation_agent.target_position = selected_point.global_position


func _follow_path(delta: float) -> void:
	if navigation_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Get the next point along the route around the buildings.
	var next_path_position := navigation_agent.get_next_path_position()
	var movement_direction := global_position.direction_to(
		next_path_position
	)

	if movement_direction == Vector2.ZERO:
		velocity = Vector2.ZERO
		return

	# Rotate the police-car image toward its movement direction.
	var desired_rotation := movement_direction.angle() + PI / 2.0

	rotation = rotate_toward(
		rotation,
		desired_rotation,
		turn_speed * delta
	)

	var current_speed := patrol_speed

	if current_state == State.CHASE:
		current_speed = chase_speed

	# Moving directly along the calculated path prevents the car
	# from driving straight into buildings during sharp turns.
	velocity = movement_direction * current_speed

	move_and_slide()


func _check_if_stuck(delta: float) -> void:
	var distance_moved := global_position.distance_to(previous_position)

	if velocity.length() > 10.0 and distance_moved < 1.0:
		stuck_timer += delta
	else:
		stuck_timer = 0.0

	previous_position = global_position

	if stuck_timer < 1.0:
		return

	stuck_timer = 0.0

	# Request a fresh path if the police car becomes stuck.
	if current_state == State.CHASE:
		navigation_agent.target_position = taxi.global_position
	elif current_state == State.SEARCH:
		navigation_agent.target_position = last_seen_position
	else:
		_choose_random_patrol_point()
