class_name PlayerUnit extends GridUnit
## Reads input and asks GridUnit to move. Holding a direction repeats,
## because we retry every frame and try_move only succeeds once the tween ends.


func _process(_delta: float) -> void:
	var dir := Vector2i.ZERO
	if Input.is_action_pressed("move_up"):
		dir = Vector2i.UP
	elif Input.is_action_pressed("move_down"):
		dir = Vector2i.DOWN
	elif Input.is_action_pressed("move_left"):
		dir = Vector2i.LEFT
	elif Input.is_action_pressed("move_right"):
		dir = Vector2i.RIGHT
	if dir != Vector2i.ZERO:
		try_move(dir)
