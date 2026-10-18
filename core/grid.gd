class_name Grid extends Node
## Converts between world positions and cells, tracks who stands where,
## and answers "where can I walk?" questions.
## Assign `ground` (a TileMapLayer) in the inspector.
## The TileSet needs a custom data layer named "walkable" (bool).

const DIRS := [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]

@export var ground: TileMapLayer

var _occupants: Dictionary = {}   # Vector2i -> GridUnit


func cell_size() -> Vector2i:
	return ground.tile_set.tile_size


func cell_to_world(cell: Vector2i) -> Vector2:
	return ground.to_global(ground.map_to_local(cell))


func world_to_cell(world_pos: Vector2) -> Vector2i:
	return ground.local_to_map(ground.to_local(world_pos))


func is_walkable(cell: Vector2i) -> bool:
	var data := ground.get_cell_tile_data(cell)
	if data == null:
		return false   # empty cell = off the map
	return data.get_custom_data("walkable")


func is_occupied(cell: Vector2i) -> bool:
	return _occupants.has(cell)


func is_free(cell: Vector2i) -> bool:
	return is_walkable(cell) and not is_occupied(cell)


func get_unit_at(cell: Vector2i) -> Node:
	return _occupants.get(cell)


func place_unit(unit: Node, cell: Vector2i) -> void:
	_occupants[cell] = unit


func move_unit(unit: Node, from: Vector2i, to: Vector2i) -> void:
	_occupants.erase(from)
	_occupants[to] = unit


func remove_unit(cell: Vector2i) -> void:
	_occupants.erase(cell)


## Flood fill (breadth-first). Returns {cell: steps_away} for every cell
## reachable within max_steps, not counting the start cell.
## Walls and other units block the way.
func get_reachable_cells(start: Vector2i, max_steps: int) -> Dictionary:
	var dist := {start: 0}
	var frontier: Array[Vector2i] = [start]
	while not frontier.is_empty():
		var current: Vector2i = frontier.pop_front()
		var d: int = dist[current]
		if d >= max_steps:
			continue
		for dir in DIRS:
			var next: Vector2i = current + dir
			if dist.has(next) or not is_free(next):
				continue
			dist[next] = d + 1
			frontier.append(next)
	dist.erase(start)
	return dist
