extends Car
class_name Player

@export var brake_force: float = 600.0

func _physics_process(delta: float) -> void:
	throttle = Input.get_action_strength("throttle")
	steering = Input.get_axis("left", "right")

	var braking = Input.get_action_strength("break")

	if braking > 0:
		throttle = 0.0
		speed = move_toward(speed, 0.0, brake_force * braking * delta)

	super._physics_process(delta)
