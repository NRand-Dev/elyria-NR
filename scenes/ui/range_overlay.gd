class_name RangeOverlay extends Node2D
## Draws translucent squares over the cells a unit can still walk to.
## Set `grid` and `unit` (your player) in the inspector.

@export var grid: Grid
@export var unit: Unit
@export var color := Color(0.3, 0.6, 1.0, 0.35)

var _cells: Array = []


func _ready() -> void:
	z_index = 10   # draw above the ground
	unit.state_changed.connect(_refresh)


func _refresh() -> void:
	_cells.clear()
	if unit.is_active and not unit.is_done() and unit.moves_left > 0:
		_cells = grid.get_reachable_cells(unit.cell, unit.moves_left).keys()
	queue_redraw()


func _draw() -> void:
	var size := Vector2(grid.cell_size())
	for c in _cells:
		var center := to_local(grid.cell_to_world(c))
		draw_rect(Rect2(center - size / 2.0, size), color)
