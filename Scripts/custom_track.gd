extends Node2D

@onready var ai_car: AICar = $"AI Car"
@onready var player_car: Car = $"Player Car"
@onready var countdown: Label = $CanvasLayer/Countdown
@export var laps:int=2
var ai_laps: int = 0
var player_laps: int = 0
var race_started: bool = false
var race_finished: bool = false


func _ready() -> void:
	$CanvasLayer/Lap.text = "Laps: %d/%d" % [player_laps, laps]
	ai_car.set_physics_process(false)
	player_car.set_physics_process(false)

	var loaded_brain = load_brain("user://best_brain.json")
	if loaded_brain == null:
		loaded_brain = load_brain("res://models/default_brain.json")

	if loaded_brain == null:
		push_error("Neither the player save nor the bundled AI brain could be loaded.")
		return

	ai_car.brain = loaded_brain
	ai_car.crashed.connect(handle_crash.bind(ai_car))
	player_car.crashed.connect(handle_crash.bind(player_car))
	start_countdown()


func load_brain(path: String) -> NeuralNetwork:
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null

	var data = JSON.parse_string(file.get_as_text())
	if not (data is Dictionary):
		return null

	var layers = data.get("layers")
	var weights = data.get("weights")
	var biases = data.get("biases")

	if not (layers is Array) or layers.size() != 3:
		return null
	if layers[0] != 6 or layers[1] != 8 or layers[2] != 2:
		return null
	if not (weights is Array) or not (biases is Array):
		return null

	var brain = NeuralNetwork.new([6, 8, 2])
	brain.weights = weights
	brain.biases = biases
	return brain


func start_countdown() -> void:
	countdown.show()

	for seconds_left in range(3, 0, -1):
		countdown.text = str(seconds_left)
		await get_tree().create_timer(1.0, false, false, true).timeout

	countdown.text = "GO!"
	$CanvasLayer/ColorRect.hide()
	race_started = true
	ai_car.set_physics_process(true)
	player_car.set_physics_process(true)

	await get_tree().create_timer(0.6, false, false, true).timeout
	countdown.hide()


func finish_race() -> bool:
	if not race_started or race_finished:
		return false

	race_finished = true
	ai_car.set_physics_process(false)
	player_car.set_physics_process(false)
	countdown.hide()
	return true


func handle_crash(car: Car) -> void:
	if not finish_race():
		return

	if car == player_car:
		lose("You crashed!")
	else:
		win("AI crashed! Train it more!")


func win(reason: String) -> void:
	$CanvasLayer/ColorRect.show()
	$CanvasLayer/WL.text = "You Win!"
	$CanvasLayer/WL.show()
	$CanvasLayer/Reason.text = reason
	$CanvasLayer/Reason.show()


func lose(reason: String) -> void:
	$CanvasLayer/ColorRect.show()
	$CanvasLayer/WL.text = "Game Over!"
	$CanvasLayer/WL.show()
	$CanvasLayer/Reason.text = reason
	$CanvasLayer/Reason.show()


func _on_start_finish_body_entered(body: Node2D) -> void:
	if not race_started or race_finished:
		return

	if body == player_car:
		player_laps += 1
		$CanvasLayer/Lap.text = "Laps: %d/%d" % [player_laps, laps]

		if player_laps >= laps and finish_race():
			win("You won!")
	elif body == ai_car:
		ai_laps += 1

		if ai_laps >= laps and finish_race():
			lose("The AI won!")


func _on_play_pressed() -> void:
	get_tree().reload_current_scene()


func _on_train_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/home_screen.tscn")
