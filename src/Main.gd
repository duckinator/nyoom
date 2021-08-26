extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	var err = get_tree().change_scene("res://Level1.tscn")
	if err != OK:
		print("Error: ", err)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
