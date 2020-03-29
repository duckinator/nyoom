extends RigidBody

var cleaning = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(5)
	timer.connect("timeout", self, "cleanup")
	add_child(timer)
	timer.start()

func cleanup():
	cleaning = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not cleaning:
		return
	
	scale -= Vector3(0.1, 0.1, 0.1)
	if scale <= Vector3(0.0, 0.0, 0.0):
		queue_free()