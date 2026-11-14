extends Node2D
class_name TrainingManager

@export var population_size:int=30
@export var generation_duration: float=20.0
@export var car_scene:PackedScene

@onready var original_time_scale: float = Engine.time_scale
@onready var original_physics_ticks: int = Engine.physics_ticks_per_second
@onready var original_max_steps: int = Engine.max_physics_steps_per_frame

var elapsed_time:float=0
var generation:int=1
var generation_ending:bool=false



var population: Array = []
var results: Array=[]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_population.call_deferred()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if generation_ending:
		return
	elapsed_time+=delta
	if elapsed_time>=generation_duration:
		generation_ending=true
		end_generation.call_deferred()
	
	
func spawn_population(brains: Array=[])->void:
	assert(brains.is_empty() or brains.size() == population_size)
	var checkpoint_nodes: Array[Area2D]= [$"../Checkpoints/1",$"../Checkpoints/2",$"../Checkpoints/3",$"../Checkpoints/4"]
	for i in range(population_size):
		var new_car=car_scene.instantiate()
		if(brains.is_empty()):
			new_car.brain=NeuralNetwork.new([6,8,2])
		else:
			new_car.brain=brains[i]
		new_car.get_node("AnimatedSprite2D").frame=randi_range(0,24)
		get_parent().add_child(new_car)
		new_car.start_position = $"../Spawnpoint".global_position
		new_car.checkpoints=checkpoint_nodes
		population.append(new_car)
		new_car.crashed.connect(handle_crash.bind(new_car))
		new_car.global_position=$"../Spawnpoint".global_position
		new_car.rotation=deg_to_rad(-90)

func handle_crash(car:AICar)->void:
	if not population.has(car):
		return
	car.update_fitness()
	results.append({"brain": car.brain,
	"fitness": car.fitness
	})
	population.erase(car)
	car.queue_free()
	if population.is_empty():
		end_generation.call_deferred()

func end_generation()->void:
	for cars in population:
		cars.update_fitness()
		results.append({"brain": cars.brain,"fitness": cars.fitness})
		cars.queue_free()
	population.clear()
	results.sort_custom(func(a, b): return a["fitness"] > b["fitness"])
	var parents=results.slice(0,5)
	var next_brains:Array=[]
	for parent in parents:
		var brain = parent["brain"]
		next_brains.append(brain)
		for i in range(5):
			next_brains.append(brain.mutated_copy())
	print("Generation: ", generation)
	$"../Camera2D/Generation".text="Generation: "+str(generation)
	$"../Camera2D/BestFitness".text="Best Fitness: %.2f"%results[0]['fitness']
	print("Best fitness: ", results[0]["fitness"])
	print("Next population: ", next_brains.size())
	var best_brain: NeuralNetwork = results[0]["brain"]
	var data = {
		"layers": best_brain.layers,
		"weights": best_brain.weights,
		"biases": best_brain.biases,
	}
	var file = FileAccess.open("user://best_brain.json", FileAccess.WRITE)
	if file == null:
		push_error("Could not save brain. Error: " + str(FileAccess.get_open_error()))
	else:
		file.store_string(JSON.stringify(data, "\t", true, true))
	results.clear()
	generation+=1
	elapsed_time=0
	spawn_population(next_brains)
	generation_ending=false


func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/home_screen.tscn")


func _on_h_slider_value_changed(value: float) -> void:
	var multiplier := int(value)
	$"../Camera2D/HSlider/Label".text="Accelerate Training: "+str(value)+"x"
	Engine.time_scale = original_time_scale * multiplier
	Engine.physics_ticks_per_second = original_physics_ticks * multiplier
	Engine.max_physics_steps_per_frame = original_max_steps * multiplier
