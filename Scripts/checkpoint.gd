extends Area2D

@export var checkpoint_index: int = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body is AICar:
		if body.next_checkpoint==checkpoint_index:
			body.reach_checkpoint(body.checkpoints.size())
