extends Car
class_name AICar


var brain:NeuralNetwork

@onready var left = $Left
@onready var front = $Front
@onready var right=$Right
@onready var half_left=$"Half Left"
@onready var half_right=$"Half Right"
@onready var sensors=[left, front, right, half_left, half_right]
var next_checkpoint: int=0
var checkpoints_passed: int=0
var fitness:float = 0.0
var checkpoints: Array[Area2D] = []
var start_position: Vector2
var previous_position:Vector2

func _physics_process(delta: float) -> void:
	var inputs=get_sensor_distances()
	inputs.append(speed/max_speed)
	
	var outputs=brain.predict(inputs)
	
	steering=outputs[0]
	throttle=outputs[1]
	super._physics_process(delta)
	update_fitness()
func get_sensor_distances()-> Array:
	var distances=[]
	for sensor in sensors:
		var max_distance = sensor.target_position.length()
		var distance = max_distance
		
		sensor.force_raycast_update()
		if sensor.is_colliding():
			distance=sensor.global_position.distance_to(sensor.get_collision_point())
		distances.append(clamp(distance/max_distance, 0, 1))
	return distances

func reach_checkpoint(total_checkpoints:int)->void:
	checkpoints_passed+=1
	next_checkpoint=(next_checkpoint+1)%total_checkpoints
	fitness = max(fitness, float(checkpoints_passed))
	
func update_fitness()->void:
	if checkpoints.is_empty():
		return
	var partial_progress:float=0.0
	var previous_checkpoint = (next_checkpoint - 1 + checkpoints.size()) % checkpoints.size()
	var next_position = checkpoints[next_checkpoint].global_position
	if checkpoints_passed == 0:
		previous_position = start_position
	else:
		previous_position = checkpoints[previous_checkpoint].global_position
	var direction=next_position-previous_position
	var relative = global_position-previous_position
	var num=relative.dot(direction)
	var dem=direction.length_squared()
	if(dem>0):
		partial_progress=clamp(num/dem,0.0,0.99)
	else:
		partial_progress=0
	var new_fitness = checkpoints_passed + partial_progress
	fitness=max(fitness, new_fitness)
