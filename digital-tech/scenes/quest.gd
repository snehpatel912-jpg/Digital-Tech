extends Node2D


@onready var drop_off: Area2D = $Dropoff
@onready var collection_place: Area2D = $Collectionplace

func _ready() -> void:
	
	if collection_place:
		collection_place.connect("item_picked_up", Callable(self, "_on_time_picked_up"))
	else:
		print("Error: Collectionplace node not found")
	
func _on_time_picked_up() -> void:
	print("Level received signal! Revealing DropOffPlace...")
	
	drop_off.visible = true
	drop_off.monitoring = true
	
	if is_instance_valid(collection_place):
		collection_place.queue_free()
	
	
