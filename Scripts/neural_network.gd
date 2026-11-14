
extends RefCounted
class_name NeuralNetwork

var layers: Array
var weights: Array = []
var biases: Array = []

func _init(layer_sizes: Array = [6, 8, 2]) -> void:
	layers = layer_sizes.duplicate()

	for layer in range(1, layers.size()):
		var layer_weights = []
		var layer_biases = []

		for neuron in range(layers[layer]):
			var neuron_weights = []

			for input in range(layers[layer - 1]):
				neuron_weights.append(randf_range(-1.25, 1.25))

			layer_weights.append(neuron_weights)
			layer_biases.append(randf_range(-1.0, 1.0))

		weights.append(layer_weights)
		biases.append(layer_biases)


func predict(inputs: Array) -> Array:
	assert(inputs.size() == layers[0])

	var values = inputs.duplicate()

	for layer in range(weights.size()):
		var outputs = []

		for neuron in range(weights[layer].size()):
			var total: float = biases[layer][neuron]

			for i in range(values.size()):
				total += values[i] * weights[layer][neuron][i]

			if layer == weights.size() - 1 and neuron == 1:
				outputs.append(1.0 / (1.0 + exp(-total)))
			else:
				outputs.append(tanh(total))

		values = outputs

	return values


func mutated_copy(rate: float = 0.1, strength: float = 0.3) -> NeuralNetwork:
	var child = NeuralNetwork.new(layers)

	child.weights = weights.duplicate(true)
	child.biases = biases.duplicate(true)

	for layer in range(child.weights.size()):
		for neuron in range(child.weights[layer].size()):

			for i in range(child.weights[layer][neuron].size()):
				if randf() < rate:
					child.weights[layer][neuron][i] += randf_range(-strength, strength)

			if randf() < rate:
				child.biases[layer][neuron] += randf_range(-strength, strength)

	return child
