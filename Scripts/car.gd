
extends CharacterBody2D
class_name Car

@export var acceleration: float = 400.0
@export var max_speed: float = 800.0
@export var drag: float = 150.0

@export var wheelbase: float = 50.0
@export var max_steering_angle: float = 35.0
@export var min_steering_angle: float = 15.0

var speed: float = 0.0
var throttle: float = 0.0
var steering: float = 0.0
signal crashed
func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING

func _physics_process(delta: float) -> void:
	move_car(delta)

func move_car(delta: float) -> void:
	if throttle > 0:
		speed += throttle * acceleration * delta
	else:
		speed = move_toward(speed, 0.0, drag * delta)

	speed = clamp(speed, 0.0, max_speed)

	var speed_ratio = speed / max_speed
	var steering_limit = lerp(max_steering_angle, min_steering_angle, speed_ratio)

	var angle = deg_to_rad(steering_limit) * clamp(steering, -1.0, 1.0)

	rotation += (speed / wheelbase) * tan(angle) * delta

	velocity = Vector2.UP.rotated(rotation) * speed

	if move_and_collide(velocity * delta):
		speed = 0.0
		crashed.emit()
