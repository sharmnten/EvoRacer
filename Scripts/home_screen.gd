extends Control


var launchable=false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var loaded_brain = load_brain("user://best_brain.json")
	if loaded_brain!=null:
		launchable=true
		$PlayCustomModel/Label.text="Race Your Model"
		$PlayCustomModel.texture_normal=load("res://Assets/Blue/Default/button_rectangle_depth_flat.png")
		$PlayCustomModel.texture_pressed=load("res://Assets/Blue/Default/button_rectangle_flat.png")
		$PlayCustomModel.texture_hover=load("res://Assets/Blue/Default/button_rectangle_depth_gradient.png")
	$AnimatedSprite2D.frame=randi_range(0,24)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/track.tscn")


func _on_train_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/training.tscn")


func _on_play_custom_model_pressed() -> void:
	if(launchable==true):
		get_tree().change_scene_to_file("res://Scene/custom_track.tscn")



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
