class_name PlayerUnit extends Unit
## Reads input. Only acts during the player group's turn.
## Needs input actions: move_up/down/left/right and pass_turn.


func _init() -> void:
	faction = &"player"


func _process(_delta: float) -> void:
	if not can_act():
		return

	if Input.is_action_just_pressed("pass_turn"):
		pass_turn()
		return

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
