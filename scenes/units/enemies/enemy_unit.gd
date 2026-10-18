class_name EnemyUnit extends Unit
## Placeholder AI: walk toward the nearest player unit, one greedy step at a
## time, until adjacent or out of movement. No pathfinding yet, so it can get
## stuck behind walls. That's expected for M2.


func take_ai_turn() -> void:
	while is_active and not is_done() and moves_left > 0:
		var target := _nearest_target()
		if target == null:
			break
		if _distance(cell, target.cell) <= 1:
			break
		var dir := _best_step(target.cell)
		if dir == Vector2i.ZERO:
			break
		if not try_move(dir):
			break
		await move_finished
	pass_turn()


func _nearest_target() -> Unit:
	var best: Unit = null
	var best_dist := 999999
	for node in get_tree().get_nodes_in_group("units"):
		var u := node as Unit
		if u == null or u.faction != &"player":
			continue
		var d := _distance(cell, u.cell)
		if d < best_dist:
			best_dist = d
			best = u
	return best


func _best_step(goal: Vector2i) -> Vector2i:
	var best := Vector2i.ZERO
	var best_dist := _distance(cell, goal)
	for dir in Grid.DIRS:
		var next: Vector2i = cell + dir
		if not grid.is_free(next):
			continue
		var d := _distance(next, goal)
		if d < best_dist:
			best_dist = d
			best = dir
	return best


func _distance(a: Vector2i, b: Vector2i) -> int:
	return absi(a.x - b.x) + absi(a.y - b.y)
