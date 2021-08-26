extends RigidBody

onready var player = get_parent().get_node('Player')

func _ready():
	set_contact_monitor(true)
	set_max_contacts_reported(5)
	var err = connect("body_entered", self, "_process_body_entered")
	if err != OK:
		print("Error: ", err)

func _process_body_entered(body):
	if body == player:
		Game.level_complete()
