extends Area2D

signal item_picked_up

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Taxi":
		print("Taxi touched the item")
		
		item_picked_up.emit()
