class_name GridUnit extends Node2D
## Anything that lives on the grid. Moves one cell at a time with a short tween.

signal move_finished

@export var grid: Grid
@export var start_cell := Vector2i.ZERO
@export var move_time := 0.12

var cell: Vector2i
var is_moving := false


func _ready() -> void:
	cell = start_cell
	global_position = grid.cell_to_world(cell)
	grid.place_unit(self, cell)


func try_move(dir: Vector2i) -> bool:
	if is_moving or dir == Vector2i.ZERO:
		return false
	var target := cell + dir
	if not grid.is_free(target):
		return false
	# Reserve the target cell immediately so nobody else can step in mid-tween.
	grid.move_unit(self, cell, target)
	cell = target
	is_moving = true
	var tween := create_tween()
	tween.tween_property(self, "global_position", grid.cell_to_world(target), move_time)
	tween.finished.connect(_on_move_done)
	return true


func _on_move_done() -> void:
	is_moving = false
	move_finished.emit()


func _exit_tree() -> void:
	if grid:
		grid.remove_unit(cell)
