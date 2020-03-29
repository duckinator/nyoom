extends RigidBody

var player
var cleaning = false
var next_impulse = null

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_parent().get_node('Player')
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
	if player.last_bullet != self:
		cleaning = true
	
	if not cleaning:
		return
	
	scale -= Vector3(0.1, 0.1, 0.1)
	if scale <= Vector3(0.0, 0.0, 0.0):
		queue_free()

func _integrate_forces(state):
	if next_impulse:
		var impulse = next_impulse
		next_impulse = null
		apply_impulse(Vector3(0, 0, 0), impulse)

func fire(impulse):
	next_impulse = impulse